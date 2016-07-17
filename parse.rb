require 'rubygems'
require 'simple-rss'
require 'open-uri'


class FetchData
    def rss url
        rss = SimpleRSS.parse open url
        return rss.items.first.description
    end
end
