require './connect_database.rb'

ActiveRecord::Schema.define do
    # drop_table "weather_table"
    create_table :subscribe_table do |table|
        table.string "user"
        table.string "location"
    end

    create_table :language_table do |table|
        table.string "language"
    end
end
