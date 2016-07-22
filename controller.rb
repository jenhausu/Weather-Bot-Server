require 'telegram/bot'
require './DB/model.rb'


token = '240556961:AAEP-A47vhju8Vy3P7C7vZZTdGseOpdmY9I'

m = Model.new

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
            m.changeLanguage("繁體中文")
            bot.api.send_message(chat_id: message.chat.id, text: "已經將資料切換成繁體中文。")
        when '/简体中文'
            m.changeLanguage("简体中文")
            bot.api.send_message(chat_id: message.chat.id, text: "已经将资料切换成简体中文。")
        when '/English'
            m.changeLanguage("English")
            bot.api.send_message(chat_id: message.chat.id, text: "Already change the data's language to English.")
        else
            bot.api.send_message(chat_id: message.chat.id, text: "I don't understand what \"" + message.text +  "\" mean ......")
        end
    end
  end
end
