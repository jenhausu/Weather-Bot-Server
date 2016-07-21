require 'active_record'

ActiveRecord::Base.establish_connection ({
    adapter:  'mysql2',
    host:     'localhost',
    database: 'weather_database',
    username: 'jenhausu',
    password: 'mypassword'
})
