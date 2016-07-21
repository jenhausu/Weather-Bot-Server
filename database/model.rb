require './connect_database.rb'
require './parse.rb'

class Weather < ActiveRecord::Base
  self.table_name = "weather_table"
    def decideUpdateOrNot

    end

    def decideLanguage
        
    end

    def fetchNewData
        f = FetchData.new
        url = 'http://rss.weather.gov.hk/rss/CurrentWeather.xml'
        l = f.nokogiri(f.rss(url), "weather", "location")
        d = f.nokogiri(f.rss(url), "weather", "degrees")
        a = {}

        l.each_with_index { |item, index|
            next if l[index] == "King's Park"
            a[l[index]] = d[index]
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
