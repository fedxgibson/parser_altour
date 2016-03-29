require 'date'

class MyParser
  def parse
    @item = ""
    @lines = []
    @columns = [0, 5, 26, 37, 52]

    puts "init parser"
    File.open("./flights", "r").each_line.with_index do |line, index|
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
    # puts result
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
          # object = parse_car date_with_item[:date], item[:item]
          # parsed_items.push(object)
        when 'HOTEL'
          # object = parse_hotel date_with_item[:date], item[:item]
          # parsed_items.push(object)
        else
        end
      end
    end
    return parsed_items
  end

  def get_type item
    type =  item.strip.match(/^(AIR|HOTEL|CAR)/)
    return type[0]
  end

  def parse_air(date, item)
      regexps = {
        each_data:  /\s{2,}/,
        confirmation_number: /REF: (.*)\n/,
        date: /(\d+) (\D{3}) (\d+)/,
        type: /^(AIR|HOTEL|CAR)/,
        from: /LV ((\w+\s?)+)\s{2,}/,
        to: /AR ((\w+\s?)+)\s{2,}/,
        aircraft_type: /EQP: (.*)\n/,
        duration: /\d+HR \d+MIN/,
        stops: /NON-STOP/,
        operated_by: /OPERATED BY (.*)\n/,
        depart: /LV.*?(\d+P)/,
        flight_number: /FLT:(\d+)/,
        arrive: /AR.*?(\d+P)/
      }
      parsed = {}
      item = item.strip
      al_flt_clss_meal = item.lines[0]

      parsed[:type] = regexps[:type].match(item)[0]
      parsed[:airline] = al_flt_clss_meal[(@columns[1]..@columns[2])].rstrip
      parsed[:flight_number] = regexps[:flight_number].match(item)[1].strip
      parsed[:class] = al_flt_clss_meal[(@columns[3]..@columns[4])].rstrip
      parsed[:meal] = al_flt_clss_meal[@columns[4]..-2].strip
      parsed[:operated_by] = regexps[:operated_by].match(item)[1].strip
      parsed[:from] = regexps[:from].match(item)[1].strip
      parsed[:aircraft_type] = regexps[:aircraft_type].match(item)[1].strip
      parsed[:depart] = regexps[:depart].match(item)[1].strip
      parsed[:duration] = regexps[:duration].match(item)[0].strip
      parsed[:to] = regexps[:to].match(item)[1].rstrip
      parsed[:stops] = regexps[:stops].match(item)[0] == 'NON-STOP'?0:1
      parsed[:arrive] = regexps[:arrive].match(item)[1].strip
      parsed[:confirmation_number] = regexps[:confirmation_number].match(item)[1]
      return parsed
  end

  def parse_car(date, item)
    return {}
  end

  def parse_hotel(date, item)
    return {}
  end
end
