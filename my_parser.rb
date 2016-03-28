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

  # def split_by_date
  #   date_indexes = []
  #   number_of_dates = 0
  #   @lines.each_with_index do |line, index|
  #     if (/(\d+ \D{3} \d+)/).match(line)
  #       number_of_dates+=1
  #       date_indexes.push(index)
  #     end
  #   end
  #
  #   if number_of_dates < 0
  #     return [@item]
  #   end
  #
  #   date_indexes.push(@lines.length)
  #   @dates = []
  #   (0..number_of_dates - 1).each do |index|
  #     @dates.push(@lines[date_indexes[index]..date_indexes[index + 1] - 1])
  #   end
  #   return @dates
  # end

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
    result = text.strip.scan(/(?:\s+)(AIR|HOTEL|CAR)((.+?)\n+(?=(?:\s+)(?:AIR|HOTEL|CAR))|.+)/m)
    # puts result
    item_objects = []
    result.each do |parsed_item|
      item_object = {
        type: parsed_item[0],
        item: parsed_item[1]
      }
      item_objects.push(item_object)
    end
    return item_objects
  end

  def extract_data dates_with_items
    parsed_items = []
    # puts dates_with_items
    dates_with_items.each do |date_with_item|
      date_with_item[:items].each do |item|
        case item[:type]
        when 'AIR'
          # parse_air date_with_item[:date], item[:item]
        when 'CAR'
          puts item
        when 'HOTEL'
          # parse_hotel date_with_item[:date] item
        else
          0
        end
      end
    end
    return 0
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
      # puts item
      item = item.strip
      # @parsed[:type] = regexps[:type].match(item)[1]
      # @parsed[:airline] = al_flt_clss_meal[(@columns[1]..@columns[2])].rstrip
      # @parsed[:flight_number] = regexps[:flight_number].match(item)[1]
      # @parsed[:class] = al_flt_clss_meal[(@columns[3]..@columns[4])].rstrip
      # @parsed[:meal] = al_flt_clss_meal[@columns[4]..-2]
      # @parsed[:operated_by] = regexps[:operated_by].match(item)[1]
      # @parsed[:from] = regexps[:from].match(item)[1]
      # @parsed[:aircraft_type] = regexps[:aircraft_type].match(item)[1]
      # @parsed[:depart] = regexps[:depart].match(item)[1]
      # @parsed[:duration] = regexps[:duration].match(item)[0]
      # @parsed[:to] = regexps[:to].match(item)[1].rstrip
      # @parsed[:stops] = regexps[:stops].match(item)[0] == 'NON-STOP'?0:1
      # @parsed[:arrive] = regexps[:arrive].match(item)[1]
      # @parsed[:confirmation_number] = regexps[:confirmation_number].match(item)[1]

      return @parsed
  end

  def parse_car(date, item)
    return {}
  end

  def parse_hotel(date, item)
    return {}
  end
end
