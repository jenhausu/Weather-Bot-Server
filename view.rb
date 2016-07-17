require 'telegram/bot'

token = '240556961:AAEP-A47vhju8Vy3P7C7vZZTdGseOpdmY9I'


Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message
    when Telegram::Bot::Types::Message
        case message.text
        when '/current_status'
            bot.api.send_message(chat_id: message.chat.id, text: "Below is your current weather:")

        when '/subscribe'
            kb = [
                Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Hong Kong', callback_data: 'Hong Kong Weather'),
            ]
            markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
            bot.api.send_message(chat_id: message.chat.id, text: 'Which location do you want to subscribe?', reply_markup: markup)
        when '/unsubscribe'
            bot.api.send_message(chat_id: message.chat.id, text: "unsubscribe")
        when '/繁體中文'
            bot.api.send_message(chat_id: message.chat.id, text: "繁體中文")
        when '/简体中文'
            bot.api.send_message(chat_id: message.chat.id, text: "简体中文")
        when '/English'
            bot.api.send_message(chat_id: message.chat.id, text: "English")
        else
            bot.api.send_message(chat_id: message.chat.id, text: "I don't understand what \"" + message.text +  "\"......")
        end


    when Telegram::Bot::Types::CallbackQuery
        # Here you can handle your callbacks from inline buttons
        if message.data == 'Hong Kong Weather'
            bot.api.send_message(chat_id: message.from.id, text: "The weather in Hong Kong is ")
        end
    end
  end
end
