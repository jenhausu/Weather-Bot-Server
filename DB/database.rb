require 'simple-rss'
require 'open-uri'
require 'nokogiri'

require './DB/connect_database.rb'


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


class FetchDataClass
    def fetchNewData datatype
        f = FetchDataClass.new
        a = f.nokogiri(f.rss, "weather", datatype)
        return a
    end

    def languageChoice
        lan = Language.new
        case lan.choice
        when "English"
            url = 'http://rss.weather.gov.hk/rss/CurrentWeather.xml'
        when "繁體中文"
            url = 'http://rss.weather.gov.hk/rss/CurrentWeather_uc.xml'
        when "简体中文"
            url = 'http://gbrss.weather.gov.hk/rss/CurrentWeather_uc.xml'
        end
        return url
    end

    def rss
        f = FetchDataClass.new
        url = f.languageChoice
        rss = SimpleRSS.parse open url
        return rss.items.first.description
    end

    def nokogiri description, dataTitle, dataType
        if dataTitle == "weather"
            html_doc = Nokogiri::HTML(description)
            dataQuantity = ((html_doc.xpath("//table[1]/tr/td").count)/2)
            a = []

            if dataType == "location"
                index = 0

                dataQuantity.times {
                    a << html_doc.xpath("//table[1]/tr/td")[index].text
                    index += 2
                }
            elsif dataType == "degrees"
                index = 1

                dataQuantity.times {
                    a << html_doc.xpath("//table[1]/tr/td")[index].text[0..1]
                    index += 2
                }
            end

            return a
        elsif dataTitle == "warning"

        end
    end
end
