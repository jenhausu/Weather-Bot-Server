require './DB/database.rb'


class Model
    def fetchNewData datatype
        f = FetchDataClass.new
        a = f.nokogiri(f.rss, "weather", datatype)
        return a
    end

    def changeLanguage language
        l = Language.new
        l.update(language)
    end


    def subscribe_add user, location
        s = SubscribeClass.new
        s.add(user, location)
    end

    def subscribed_show user
        s = SubscribeClass.new
        return s.read(user)
    end

    def unsubscribe user, location
        s = SubscribeClass.new
        s.delete(user, location)
    end

    def subscribe_ShowAllUser
        s = SubscribeClass.new
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
        m = Model.new
        l = m.fetchNewData("location")
        d = m.fetchNewData("degrees")

        s = m.subscribed_show(user)

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
