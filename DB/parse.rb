require 'simple-rss'
require 'open-uri'
require 'nokogiri'

require './model.rb'


class FetchData
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

    def fetchNewData
      #code
    end

    def rss FetchData.new.languageChoice
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
