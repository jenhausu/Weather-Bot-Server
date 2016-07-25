require 'simple-rss'
require 'open-uri'
require 'nokogiri'

require './DB/connect_database.rb'


class Subscribe_Table < ActiveRecord::Base
    self.table_name = "subscribe_table"
    def add user, location
        s = Subscribe_Table.new(user: user, location: location)
        s.save!
    end

    def read user
        s = Subscribe_Table.where(user: user)
        return s
    end

    def read_all
        s = Subscribe_Table.all
        return s
    end

    def delete user, location
        s = Subscribe_Table.find_by(user: user, location: location)
        s.destroy
    end
end

class Warning_Table < ActiveRecord::Base
    self.table_name = "warning_table"
    def add user
        w = Warning_Table.new(user: user)
        w.save!
    end

    def delete user
        w = Warning_Table.find_by(user: user)
        w.destroy
    end
end

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
