require 'date'

class MyParser
  def parse
    @full_text = ""
    @lines = []
    @columns = [0, 5, 26, 37, 52]

    puts "init parser"
    File.open("./flights", "r").each_line.with_index do |line, index|
      # puts index
      @lines.push(line)
      @full_text+= line
    end
    # puts full_text
    # al_flt_clss_meal = lines[0]
    split_by_item split_by_date
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
  #     return [@full_text]
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
    return @full_text.scan(/((?:\d+ \D{3} \d+)(?:.+?(?=\d+ \D{3} \d+)|.+))/m)
  end

  def split_by_item dates_with_items
    puts dates_with_items[0]
    return 0
  end

  # def extract_data
  #   regexps = {
  #     each_data:  /\s{2,}/,
  #     confirmation_number: /REF: (.*)\n/,
  #     date: /(\d+) (\D{3}) (\d+)/,
  #     type: /(AIR|HOTEL|CAR)\s{3}/,
  #     from: /LV ((\w+\s?)+)\s{2,}/,
  #     to: /AR ((\w+\s?)+)\s{2,}/,
  #     aircraft_type: /EQP: (.*)\n/,
  #     duration: /\d+HR \d+MIN/,
  #     stops: /NON-STOP/,
  #     operated_by: /OPERATED BY (.*)\n/,
  #     depart: /LV.*?(\d+P)/,
  #     flight_number: /FLT:(\d+)/,
  #     arrive: /AR.*?(\d+P)/
  #   }
  #
  #   @parsed[:type] = regexps[:type].match(full_text)[1]
  #   @parsed[:airline] = al_flt_clss_meal[(@columns[1]..@columns[2])].rstrip
  #   @parsed[:flight_number] = regexps[:flight_number].match(full_text)[1]
  #   @parsed[:class] = al_flt_clss_meal[(@columns[3]..@columns[4])].rstrip
  #   @parsed[:meal] = al_flt_clss_meal[@columns[4]..-2]
  #   @parsed[:operated_by] = regexps[:operated_by].match(full_text)[1]
  #   @parsed[:from] = regexps[:from].match(full_text)[1]
  #   @parsed[:aircraft_type] = regexps[:aircraft_type].match(full_text)[1]
  #   @parsed[:depart] = regexps[:depart].match(full_text)[1]
  #   @parsed[:duration] = regexps[:duration].match(full_text)[0]
  #   @parsed[:to] = regexps[:to].match(full_text)[1].rstrip
  #   @parsed[:stops] = regexps[:stops].match(full_text)[0] == 'NON-STOP'?0:1
  #   @parsed[:arrive] = regexps[:arrive].match(full_text)[1]
  #   @parsed[:confirmation_number] = regexps[:confirmation_number].match(full_text)[1]
  #
  #   return @parsed
  # end
end
