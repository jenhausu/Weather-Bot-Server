require 'simple-rss'
require 'open-uri'
require 'nokogiri'

require './DB/connect_database.rb'


class Language < ActiveRecord::Base
    self.table_name = "language_table"
    def choice
        l = Language.first
        if l
            return l.language
        else
            return "English"
        end
    end

    def update c
        l = Language.first
        if l
            l.language = c
            l.save!
        else
            l = Language.new(language: "#{c}")
            l.save!
        end

    end
end

class SubscribeClass < ActiveRecord::Base
    self.table_name = "subscribe_table"
    def add user, location
        s = SubscribeClass.new(user: user, location: location)
        s.save!
    end

    def read user
        s = SubscribeClass.where(user: user)
        return s
    end

    def read_all
        s = SubscribeClass.all
        return s
    end

    def delete user, location
        s = SubscribeClass.find_by(user: user, location: location)
        s.destroy
    end
end

class FetchDataClass
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
