require './DB/database.rb'


class Subscribe_Model
    def subscribe_add user, location
        s = Subscribe_Table.new
        s.add(user, location)
    end

    def subscribed_show user
        s = Subscribe_Table.new
        t = Translation_Model.new

        subscribed = s.read(user)
        a = []

        subscribed.each_with_index { |item, index|
            l = Language_Model.new
            language = l.choice(user)

            case language
            when "English"
                a << t.translate(subscribed[index].location, "English", "English")
            when "繁體中文"
                a << t.translate(subscribed[index].location, "English", "繁體中文")
            when "简体中文"
                a << t.translate(subscribed[index].location, "English", "简体中文")
            end
        }

        return a
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
        l = f.fetchNewData(user, "weather", "location")
        d = f.fetchNewData(user, "weather", "degrees")

        h = {}
        l.each_with_index { |item, index|
            h[l[index]] = d[index]
        }

        s = Subscribe_Model.new.subscribed_show(user)

        a = {}
        s.each_with_index { |item, index|
            a[item] = h[item]
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

    def fetchWarning user_id
        f = FetchData_Model.new
        a = f.nokogiri(user_id, "warning", "not need")

        return a
    end

    def warning_change
        o = ObserveWarning_Table.new

        rss = SimpleRSS.parse open 'http://rss.weather.gov.hk/rss/WeatherWarningBulletin.xml'
        d = rss.items.first.description
        html_doc = Nokogiri::HTML(d)
        t = html_doc.xpath("//text()")

        if t.last.to_s.length == 62

            if t.last.to_s[39..61] == o.read[0].dispatche_time.to_s
                return false
                else
                o.update(t.last.to_s[39..61])
                return true
            end
            else
            if t.last.to_s[34..56] == o.read[0].dispatche_time.to_s
                return false
                else
                o.update(t.last.to_s[34..56])
                return true
            end
        end
    end

    def warning_subscribed_user
        w = Warning_Table.new
        a = []

        w.read.each { |item|
            a << item.user
        }

        return a
    end
end

class FetchData_Model
    def fetchNewData user_id, datatype1, datatype2
        f = FetchData_Model.new
        a = f.nokogiri(user_id, datatype1, datatype2)
        return a
    end

    def languageChoice user_id, dataTitle
        l = Language_Model.new
        language = l.choice(user_id)
        if dataTitle == "weather"
            case language
            when "English"
                url = 'http://rss.weather.gov.hk/rss/CurrentWeather.xml'
            when "繁體中文"
                url = 'http://rss.weather.gov.hk/rss/CurrentWeather_uc.xml'
            when "简体中文"
                url = 'http://gbrss.weather.gov.hk/rss/CurrentWeather_uc.xml'
            end
        elsif dataTitle == "warning"
            case language
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

    def rss user_id, dataTitle
        f = FetchData_Model.new
        url = f.languageChoice(user_id, dataTitle)
        rss = SimpleRSS.parse open url
        return rss.items.first.description
    end

    def nokogiri user_id, dataTitle, dataType
        d = FetchData_Model.new.rss(user_id, dataTitle)
        html_doc = Nokogiri::HTML(d)

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
            l = Language_Model.new
            case l.choice(user_id)
            when "English"
                return html_doc.xpath("//text()")
            when "繁體中文"
                html_doc = Nokogiri::HTML(d, nil, "utf-8")
                return html_doc.xpath("//text()")
            when "简体中文"
                html_doc = Nokogiri::HTML(d, nil, "utf-8")
                return html_doc.xpath("//text()")
            end
        end
    end
end

class Language_Model
    def changeLanguage user, language
        l = Language_Table.new
        l.update(user, language)
    end

    def choice user
        l = Language_Table.new
        return l.read(user)
    end
end

class Translation_Model
    def translate text, from, to
        t = Translation_Table.new
        return t.traslate(t.identifyIndex(text, from), to)
    end
end
