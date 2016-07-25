require 'telegram/bot'
require 'rufus-scheduler'
require './DB/model.rb'


token = '240556961:AAEP-A47vhju8Vy3P7C7vZZTdGseOpdmY9I'

f = FetchData_Model.new
s = Subscribe_Model.new
l = Language_Model.new
w = Warning_Model.new

scheduler = Rufus::Scheduler.new

Telegram::Bot::Client.run(token) do |bot|
    scheduler.every '15s' do
        u = s.subscribe_ShowAllUser
        u.each { |user_id|
            t = ""
            a = s.subscribed_push(user_id)

            a.each { |key, value|
                t += key.to_s + ": " + value.to_s + " ˚C\n"
            }
            bot.api.send_message(chat_id: user_id, text: t)
        }

        if w.warning_change
            u = w.warning_subscribed_user
            u.each { |user_id|
                a = w.fetchWarning
                a.each { |item|
                    bot.api.send_message(chat_id: user_id, text: item)
                }
            }
        end
    end

  bot.listen do |message|
    case message
    when Telegram::Bot::Types::Message
        case message.text
        when '/start'
            t = "Here are the commands you can use:\n"
            t += "/current_weather - Watch the current weather status.\n"
            t += "/weather_subscribe - subscribe weather\n"
            t += "/weather_unsubscribe -  unsubscribe weather\n"
            t += "/current_warning - Look at the weather warning.\n"
            t += "/warning_subscribe - subscribe warning\n"
            t += "/warning_unsubscribe -  unsubscribe warning\n"
            t += "/繁體中文 -  轉換資料的語言為繁體中文\n"
            t += "/简体中文 - 转换资料的语言为简体中文\n"
            t += "/English - change the data’s language to English"

            bot.api.send_message(chat_id: message.chat.id, text: t)
        when '/current_weather'
            location = f.fetchNewData("weather", "location")
            degrees = f.fetchNewData("weather", "degrees")
            t = ""

            location.count.times { |index|
                t += location[index] + ": " + degrees[index] + " ˚C\n"
            }
            bot.api.send_message(chat_id: message.chat.id, text: t)
        when '/current_warning'
            a = w.fetchWarning
            a.each { |item|
                bot.api.send_message(chat_id: message.chat.id, text: item)
            }
        when '/weather_subscribe'
            kb = []
            location = f.fetchNewData("location")
            c = ["Hong Kong Observatory", "King's Park", "Wong Chuk Hang", "Ta Kwu Ling", "Lau Fau Shan", "Tai Po", "Sha Tin", "Tuen Mun", "Tseung Kwan O", "Sai Kung",
                            "Cheung Chau", "Chek Lap Kok", "Tsing Yi", "Shek Kong", "Tsuen Wan Ho Koon", "Tsuen Wan Shing Mun Valley", "Hong Kong Park", "Shau Kei Wan",
                             "Kowloon City", "Happy Valley", "Wong Tai Sin", "Stanley", "Kwun Tong", "Sham Shui Po", "Kai Tak Runway Park", "Yuen Long Park"]

            location.each_with_index { |item, index|
                kb << Telegram::Bot::Types::InlineKeyboardButton.new(text:(index + 1).to_s + ". " + item, callback_data: "s" + c[index])
            }

            markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb, one_time_keyboard: true)
            bot.api.send_message(chat_id: message.chat.id, text: "Here are " + location.count.to_s + " locations you can subscribe.", reply_markup: markup)
        when '/weather_unsubscribe'
            kb = []
            location = s.subscribed_show(message.chat.id)

            location.each_with_index { |item, index|
                kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: (index + 1).to_s + ". " + location[index].location, callback_data: "u" + location[index].location)
            }

            markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb, one_time_keyboard: true)
            bot.api.send_message(chat_id: message.chat.id, text: "Here are " + location.count.to_s + " locations you have subscribe.", reply_markup: markup)
        when '/warning_subscribe'
            w.warning_subscribe(message.chat.id)
            bot.api.send_message(chat_id: message.chat.id, text: "Subscribe warning successfuly")
        when '/warning_unsubscribe'
            w.warning_unsubscribe(message.chat.id)
            bot.api.send_message(chat_id: message.chat.id, text: "Unubscribe warning successfuly")
        when '/繁體中文'
            l.changeLanguage("繁體中文")
            bot.api.send_message(chat_id: message.chat.id, text: "已經將資料切換成繁體中文。")
        when '/简体中文'
            l.changeLanguage("简体中文")
            bot.api.send_message(chat_id: message.chat.id, text: "已经将资料切换成简体中文。")
        when '/English'
            l.changeLanguage("English")
            bot.api.send_message(chat_id: message.chat.id, text: "Already change the data's language to English.")
        else
            bot.api.send_message(chat_id: message.chat.id, text: "I don't understand what \"" + message.text.to_s +  "\" mean ......")
        end
    when Telegram::Bot::Types::CallbackQuery
        scheduler.pause
        if message.data.first == "s"
            s.subscribe_add(message.from.id.to_s, message.data[1..message.data.length-1])
            bot.api.send_message(chat_id: message.from.id, text: "Subscribe successfuly!")
        else
            s.unsubscribe(message.from.id, message.data[1..message.data.length-1])
            bot.api.send_message(chat_id: message.from.id, text: "Unsubscribe successfuly!")
        end
        scheduler.resume
    end
  end
end
