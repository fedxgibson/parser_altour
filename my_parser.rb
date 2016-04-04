require 'date'

class MyParser
  def parse
    @item = ""
    @lines = []
    @columns = [0, 5, 26, 37, 52]

    puts "init parser"
    File.open("./flights5", "r").each_line.with_index do |line, index|
      # puts index
      @lines.push(line)
      @item+= line
    end
    # puts item
    # al_flt_clss_meal = lines[0]
    extract_data split_by_item split_by_date
  end

  private

  def split_by_date
    #scans for date + items pattern until next date
    return @item.scan(/((?:\d+ \D{3} \d+)?(?:.+?(?=\d+ \D{3} \d+)|.+))/m)
  end

  def split_by_item dates_with_items
    # puts dates_with_items
    dates_with_items_formated = []

    dates_with_items.each do |date_item|
      date_with_item_object = {}
      date = /(\d+ \D{3} \d+)(.+)/.match(date_item[0])
      items = /(?:\d+ \D{3} \d+\s+?-\s+?\w+)?(.+)/m.match(date_item[0])[1]
      date_with_item_object[:date] =  Date.parse(date[1]) unless date.nil?
      date_with_item_object[:items] = itemize items
      dates_with_items_formated.push(date_with_item_object)
    end
    return dates_with_items_formated
  end

  def itemize text
    result = text.strip.scan(/(.+?\n+(?=(?:\s+)(?:AIR|HOTEL|CAR))|.+)/m)
    item_objects = []
    result.each do |parsed_item|
      item_objects.push(parsed_item[0])
    end
    return item_objects
  end

  def extract_data dates_with_items
    parsed_items = []
    # puts dates_with_items
    dates_with_items.each do |date_with_item|
      date_with_item[:items].each do |item|
        case get_type item
        when 'AIR'
          object = parse_air date_with_item[:date], item
          parsed_items.push(object)
        when 'CAR'
          object = parse_car date_with_item[:date], item
          parsed_items.push(object)
        when 'HOTEL'
          object = parse_hotel date_with_item[:date], item
          parsed_items.push(object)
        else
        end
      end
    end
    return parsed_items
  end

  def get_type item
    type =  item.strip.match(/^(AIR|HOTEL|CAR)/)
    return type != nil ? type[0] : nil
  end

  def parse_air(date, item)
      regexps = {
        each_data:  /\s{2,}/,
        confirmation_number: /REF: (.*)\n/,
        date: /(\d+) (\D{3}) (\d+)/,
        type: /^(AIR|HOTEL|CAR)/,
        from_location: /LV ((\w+\s?)+)\s{2,}/,
        to_location: /AR ((\w+\s?)+)\s{2,}/,
        aircraft_type: /EQP: (.*)\n/,
        duration: /\d+HR \d+MIN/,
        stops: /NON-STOP/,
        operated_by: /OPERATED BY (.*)\n/,
        flight_number: /FLT:(\d+)/,
        leaving_at: /LV.*?(\d+)(P|A)/,
        arriving_at: /AR.*?(\d+)(P|A)/,
        seat: /SEAT-(.*?)\s/
      }
      parsed = {}
      item = item.strip
      al_flt_clss_meal = item.lines[0]

      parsed[:type] = check_regexps regexps[:type].match(item), 1
      parsed[:airline] = check_regexps al_flt_clss_meal[(@columns[1]..@columns[2])], nil
      parsed[:flight_number] = check_regexps regexps[:flight_number].match(item), 1
      parsed[:passage_class] = check_regexps al_flt_clss_meal[(@columns[3]..@columns[4])], nil
      parsed[:meal] = al_flt_clss_meal[@columns[4]..-2], nil
      parsed[:operated_by] = check_regexps regexps[:operated_by].match(item), 1
      parsed[:from_location] = check_regexps regexps[:from_location].match(item), 1
      parsed[:aircraft_type] = check_regexps regexps[:aircraft_type].match(item), 1
      parsed[:duration] = check_regexps regexps[:duration].match(item), 0
      parsed[:to_location] = check_regexps regexps[:to_location].match(item), 1
      stops = regexps[:stops].match(item)
      parsed[:stops] = stops != nil ? stops[0] == 'NON-STOP'?0:1 : 1
      parsed[:confirmation_number] = check_regexps regexps[:confirmation_number].match(item), 1
      lv_hour = regexps[:leaving_at].match(item)
      parsed[:leaving_at] = get_dateTime_P lv_hour, date
      ar_hour = regexps[:arriving_at].match(item)
      parsed[:arriving_at] = get_dateTime_P ar_hour, date 
      parsed[:seat] =  check_regexps regexps[:seat].match(item), 1
      return parsed
  end

  def parse_car(date, item)
    regexps = {
      type: /(AIR|HOTEL|CAR)/,
      rent_car_name: /CAR\s*.*?\s{2,}(.*?)\s{2,}/,
      pick_up_date: /PICK\sUP-(\d*)/,
      location: /CAR\s*(.*?)\s\s/,
      return_date: /RETURN-(.*?)\s/,
      type_car: /CAR\s*.*?\s{2,}(.*?)\s{2,}(.*)/,
      confirmation_number: /CONFIRMATION\s*NUMBER\s+(.*?)\s+/,
      price: /APPROX\sRENTAL\sCOST\s+(.*?)\s/
    }
    parsed = {}
    item = item.rstrip
    
    parsed[:type] = check_regexps regexps[:type].match(item), 1
    parsed[:rent_car_name] = check_regexps regexps[:rent_car_name].match(item.lines[0].strip), 1
    parsed[:pick_up_date] = get_dateTime regexps[:pick_up_date].match(item), date
    parsed[:location] = check_regexps regexps[:location].match(item), 1
    parsed[:return_date] = get_dateTime_Month regexps[:return_date].match(item), date
    parsed[:type_car] = check_regexps regexps[:type_car].match(item), 2
    parsed[:confirmation_number] = check_regexps regexps[:confirmation_number].match(item), 1
    parsed[:price] = check_regexps regexps[:price].match(item), 1
    return parsed
  end

  def parse_hotel(date, item)
    regexps = {
      type: /(AIR|HOTEL|CAR)/,
      hotel_name: /(.*?)(\d)/,
      number_of_rooms: /(\d*)\s*?ROOM/,
      phone: /FONE\s*(.*?)\s/,
      rate: /RATE-(.*)?USD/,
      check_out: /OUT-(.*?)\s/,
      confirmation_number: /CONFIRMATION\s*?(.*?)\n/,
      fax: /FAX\s*(.*?)\s/,
      total_cost: /(\d+\.\d+)\sUSD\sAPPROXIMATE\sTOTAL\sPRICE/
    }
    parsed = {}
    item = item.rstrip

    parsed[:type] = check_regexps regexps[:type].match(item), 1
    linea = item.lines[2] != nil ? item.lines[2].strip : nil
    parsed[:hotel_name] = check_regexps regexps[:hotel_name].match(linea), 1
    parsed[:number_of_rooms] = check_regexps regexps[:number_of_rooms].match(item), 1
    parsed[:phone] = check_regexps regexps[:phone].match(item), 1
    parsed[:rate] = check_regexps regexps[:rate].match(item), 1
    check_out_date = get_dateTime_Month regexps[:check_out].match(item), date
    parsed[:check_out] = check_out_date
    parsed[:check_in] = DateTime.new(date.year, date.month, date.day, 12, 0, 0)
    parsed[:confirmation_number] = check_regexps regexps[:confirmation_number].match(item), 1
    parsed[:fax] = check_regexps regexps[:fax].match(item), 1
    parsed[:total_cost] = check_regexps regexps[:total_cost].match(item), 1
    return parsed
  end

  def check_regexps(regexps, pos)
    if pos != nil
      return regexps != nil ? regexps[pos].strip : nil
    else
      return regexps != nil ? regexps.strip : nil
    end
  end

  def get_dateTime_P(hour, date)
    if hour != nil and date != nil
      hora_aux = (hour[1].length == 3) ? '0' + hour[1] : hour[1]
      hora = (hour[2] == 'P') ? ((hora_aux[0..1].to_i + 12) % 24) : hora_aux[0..1].to_i 
      min = hora_aux[2..3].to_i
      return DateTime.new(date.year, date.month, date.day, hora, min, 0)
    end
    return nil
  end

  def get_dateTime(hour, date)
    if hour != nil
      hora = hour[1][0..1]
      min = hour[1][2..3]
      return DateTime.new(date.year, date.month, date.day, hora.to_i, min.to_i, 0)
    end
    return nil
  end

  def get_dateTime_Month(date_aux, date)
    if date_aux != nil
      if date_aux[1].length == 5
        return DateTime.parse(date_aux[1])
      else
        hora = date_aux[1].length == 10 ? date_aux[1][6..7] : date_aux[1][6]
        min =  date_aux[1].length == 10 ? date_aux[1][8..9] : date_aux[1][8]
        parse_date = date_aux[1][0..4].to_s + ' ' + hora + ':' + min
        return DateTime.parse(parse_date)
      end
    end
  end
end