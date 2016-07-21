require './connect_database.rb'

ActiveRecord::Schema.define do
    # drop_table "weather_table"
    create_table :weather do |table|
        table.string "location"
        table.integer "degrees"
        table.datetime "updated_at"
    end
end
