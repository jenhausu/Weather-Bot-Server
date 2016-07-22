require './DB/database.rb'

class Model
    def fetchNewData datatype
        f = FetchDataClass.new
        a = f.nokogiri(f.rss, "weather", datatype)
        return a
    end
end
