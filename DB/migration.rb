require './connect_database.rb'


ActiveRecord::Schema.define do
    rename_table "weather_table", "weather"
    # rename_table "weather", "weather_table"
end
