require 'telegram/bot'
require './DB/model.rb'


token = '240556961:AAEP-A47vhju8Vy3P7C7vZZTdGseOpdmY9I'

m = Model.new

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::Message
        case message.text
        when '/start'
            t = "Here are the commands you can use:\n"
            t += "/current_weather - Watch the current weather status.\n"
            t += "/subscribe - subscribe weather\n"
            t += "/unsubscribe -  unsubscribe weather\n"
            t += "/繁體中文 -  轉換資料的語言為繁體中文\n"
            t += "/简体中文 - 转换资料的语言为简体中文\n"
            t += "/English - change the data’s language to English"

            bot.api.send_message(chat_id: message.chat.id, text: t)
        when '/current_weather'
            location = m.fetchNewData("location")
            degrees = m.fetchNewData("degrees")
            t = ""

            location.count.times { |index|
                t += location[index] + ": " + degrees[index] + " ˚C\n"
            }
            bot.api.send_message(chat_id: message.chat.id, text: t)
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
