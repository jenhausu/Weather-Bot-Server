require 'telegram/bot'
require './parse.rb'


token = '240556961:AAEP-A47vhju8Vy3P7C7vZZTdGseOpdmY9I'


Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::Message
        case message.text

        when '/current_status'
            bot.api.send_message(chat_id: message.chat.id, text: "Below is your current weather:")
        when '/subscribe'
            f = FetchData.new
            location = f.nokogiri(f.rss('http://rss.weather.gov.hk/rss/CurrentWeather_uc.xml'), "weather", "location")
            kb = []

            location.count.times { |index|
                kb << Telegram::Bot::Types::KeyboardButton.new(text:(index + 1).to_s + ". " + location[index])
            }

            markup = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: kb, one_time_keyboard: true, resize_keyboard: true)
            bot.api.send_message(chat_id: message.chat.id, text: "Here are " + location.count.to_s + " locations you can subscribe.", reply_markup: markup)
        when '/unsubscribe'
            bot.api.send_message(chat_id: message.chat.id, text: "unsubscribe")
        when '/繁體中文'
            bot.api.send_message(chat_id: message.chat.id, text: "繁體中文")
        when '/简体中文'
            bot.api.send_message(chat_id: message.chat.id, text: "简体中文")
        when '/English'
            bot.api.send_message(chat_id: message.chat.id, text: "English")
        else
            bot.api.send_message(chat_id: message.chat.id, text: "I don't understand what \"" + message.text +  "\" mean ......")
        end
    end
  end
end
