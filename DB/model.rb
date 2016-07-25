require './DB/database.rb'


class Subscribe_Model
    def subscribe_add user, location
        s = Subscribe_Table.new
        s.add(user, location)
    end

    def subscribed_show user
        s = Subscribe_Table.new
        return s.read(user)
    end

    def unsubscribe user, location
        s = Subscribe_Table.new
        s.delete(user, location)
    end

    def subscribe_ShowAllUser
        s = Subscribe_Table.new
        all = s.read_all
        a = []

        if all.count > 0
            lastUser = all[0].user
            a[0] = all[0].user
        end

        all.each_with_index { |all_item, all_index|
            if all[all_index].user != lastUser
                a.each_with_index { |item, index|
                    if item == all[all_index].user
                        break
                    end

                    if index == (a.count - 1)
                        a << all[all_index].user
                        lastUser = all[all_index].user
                    end
                }
            end
        }
        return a
    end

    def subscribed_push user
        f = FetchData_Model.new
        l = f.fetchNewData("weather", "location")
        d = f.fetchNewData("weather", "degrees")


        s = Subscribe_Model.new.subscribed_show(user)

        h = {}
        l.each_with_index { |item, index|
            h[l[index]] = d[index]
        }

        a = {}
        s.each_with_index { |item, index|
            a[s[index].location] = h[s[index].location]
        }
        return a
    end
end

class Warning_Model
    def warning_subscribe user
        w = Warning_Table.new
        w.add(user)
    end

    def warning_unsubscribe user
        w = Warning_Table.new
        w.delete(user)
    end

    def fetchWarning
        f = FetchData_Model.new
        a = f.nokogiri("warning", "not need")

        return a
    end
    
    def warning_push
        w = Warning_Table.new
        return w.read_all
    end
end

class FetchData_Model
    def fetchNewData datatype1, datatype2
        f = FetchData_Model.new
        a = f.nokogiri(datatype1, datatype2)
        return a
    end

    def languageChoice dataTitle
        lan = Language.new
        if dataTitle == "weather"
            case lan.choice
            when "English"
                url = 'http://rss.weather.gov.hk/rss/CurrentWeather.xml'
            when "繁體中文"
                url = 'http://rss.weather.gov.hk/rss/CurrentWeather_uc.xml'
            when "简体中文"
                url = 'http://gbrss.weather.gov.hk/rss/CurrentWeather_uc.xml'
            end
        elsif dataTitle == "warning"
            case lan.choice
            when "English"
                url = 'http://rss.weather.gov.hk/rss/WeatherWarningBulletin.xml'
            when "繁體中文"
                url = 'http://rss.weather.gov.hk/rss/WeatherWarningBulletin_uc.xml'
            when "简体中文"
                url = 'http://gbrss.weather.gov.hk/rss/WeatherWarningBulletin_uc.xml'
            end
        end

        return url
    end

    def rss dataTitle
        f = FetchData_Model.new
        url = f.languageChoice(dataTitle)
        rss = SimpleRSS.parse open url
        return rss.items.first.description
    end

    def nokogiri dataTitle, dataType
        html_doc = Nokogiri::HTML(FetchData_Model.new.rss(dataTitle))

        if dataTitle == "weather"
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
            return html_doc.xpath("//text()")
        end
    end
end

class Language_Model
    def changeLanguage language
        l = Language.new
        l.update(language)
    end
end
