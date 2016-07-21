require './DB/connect_database.rb'
require './DB/parse.rb'

class Language < ActiveRecord::Base
    self.table_name = "language_table"
    def choice # read
        l = Language.first
        if l
            return l[language]
        else
            return "English"
        end
    end

    def update
        l = Language.first
        l = Language.update(a)
        l.save!
    end
end


class Weather < ActiveRecord::Base
  self.table_name = "weather_table"
    def decideUpdateOrNot

    end

    def fetchNewData
        url = 'http://rss.weather.gov.hk/rss/CurrentWeather.xml'
        f = FetchData.new

        loca = f.nokogiri(f.rss(url), "weather", "location")
        degre = f.nokogiri(f.rss(url), "weather", "degrees")
        a = {}

        loca.each_with_index { |item, index|
            next if loca[index] == "King's Park"
            a[loca[index]] = degre[index]
        }
        return a
    end

    def create a
        w = Weather.new(a)
        w.save!
    end

    def update a
        w = Weather.first
        w = Weather.update(a)
        w.save!
    end

    def read

    end
end

w = Weather.new
puts w.fetchNewData

class Warning < ActiveRecord::Base
end
