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
