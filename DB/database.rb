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
