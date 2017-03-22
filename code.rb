require 'discordrb'
require 'configatron'
require 'open-uri'
require_relative 'config.rb'

bot = Discordrb::Commands::CommandBot.new token: configatron.token, client_id: 291390171151335424, prefix: ['A^', '<@291390171151335424> '], ignore_bots: true

bot.bucket :normal, limit: 5, time_span: 15, delay: 3

bot.ready do |event|
  sleep 180
  bot.game = "Use A^cmds or A^info"
  sleep 180
  bot.game = "on #{bot.servers.count} servers!"
  redo
end

bot.server_create do |event|
  all_count = event.server.member_count
  members_count = event.server.online_members(include_idle: true, include_bots: false).count
  maths = (members_count / all_count) * 100.0
  if maths >= 50
    event.server.leave
    bot.send_message(281280895577489409, "Automatically left `#{event.server.name}` (ID: #{event.server.id}) due to high online user to bot ratio (#{maths}% bots)")
  else
    bot.send_message(281280895577489409, "CahBot Alpha just joined `#{event.server.name}` (ID: #{event.server.id}), owned by `#{event.server.owner.distinct}` (ID: #{event.server.owner.id}), the server count is now #{bot.servers.count}")
  end
end

bot.server_delete do |event|
  bot.send_message(281280895577489409, "CahBot Alpha just left `#{event.server.name}` (ID: #{event.server.id}), the server count is now #{bot.servers.count}")
end

bot.command(:die, help_available: false) do |event|
  if event.user.id == 228290433057292288
    bot.send_message(event.channel.id, 'CahBot Alpha is shutting down')
    exit
  else
    'Sorry, only Cah can kill me'
  end
end

bot.command(:eval, help_available: false) do |event, *code|
  if event.user.id == 228290433057292288
    begin
      event << 'Eval Complete!'
      event << ''
      event << "Output: ```#{eval code.join(' ')} ```"
    rescue => e
      event << 'Eval Failed!'
      event << ''
      event << "Output: ```#{e} ```"
    end
  else
    'Sorry, only Cah can eval stuff'
  end
end

bot.command(:restart, help_available: false) do |event|
  if event.user.id == 228290433057292288
    begin
      event.respond ['Into the ***fuuuutttttuuuuurrrreeee***', 'Please wait...', 'How about n—', 'Can do :thumbsup::skin-tone-1:', 'Pong! Hey, that took... Oh wait, wrong command', 'Ask again at a later ti—'].sample
      exec('bash restart.sh')
    end
  else
    'Sorry, only Cah can update me'
  end
end

bot.command(:set, help_available: false) do |event, action, args|
  if event.user.id == 228290433057292288
    case action
    when 'avatar'
      open(args.to_s) { |pic| event.bot.profile.avatar = pic }
    when 'username'
      name = args.to_s
      event.respond "Username set to `#{bot.profile.username = name}`"
    when 'game'
      bot.game = args.to_s
      event.respond 'GAME SET!'
    when 'status'
      online = bot.on
      idle = bot.idle
      invis = bot.invisible
      dnd = bot.dnd
      args.join nil
      "Status Changed!"
    else
      'I don\'t know what to do!'
    end
  else
    'Sorry, only Cah can set stuff'
  end
end

bot.command(:ban, help_available: false, required_permissions: [:ban_members], permission_message: 'Heh, sorry, but you need the Ban Members permission to use this command', max_args: 1, min_args: 1, usage: 'A^ban <mention>') do |event, *args|
  bot_profile = bot.profile.on(event.server)
  can_do_the_magic_dance = bot_profile.permission?(:ban_members)
  if can_do_the_magic_dance == true
    if !event.message.mentions.empty?
      begin
        mention = bot.parse_mention("#{args.join}").id
        event.server.ban("#{mention}", message_days = 7)
        event.respond ["<@#{mention}> has been beaned, the past 7 days of messages from them have been deleted", "<@#{mention}> has been banned, the past 7 days of messages from them have been deleted"]
      rescue => e
        event.respond "The user you are trying to ban has a role higher than/equal to me. If you believe this is a mistake, report this to the CB Server"
        bot.send_message(281280895577489409, "ERROR on server #{event.server.name} (ID: #{event.server.id}) for command `A^ban`, `#{e}`")
      else
        event.respond "Sorry, but I do not have the \"Ban Members\" permission"
      end
    else
      event.respond "Sorry, but you need to mention the person you want to ban"
    end
  end
  bot.send_message(281280895577489409, "^ban | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:kick, help_available: false, required_permissions: [:kick_members], permission_message: 'Heh, sorry, but you need the Kick Members permission to use this command', max_args: 1, min_args: 1, usage: 'A^kick <mention>') do |event, *args|
  bot_profile = bot.profile.on(event.server)
  can_do_the_other_magic_dance = bot_profile.permission?(:kick_members)
  if can_do_the_other_magic_dance == true
    if !event.message.mentions.empty?
      begin
        mention = bot.parse_mention("#{args.join}").id
        event.server.kick(mention)
        event.respond ["<@#{mention}> has been keked", "<@#{mention}> has been kicked"]
      rescue => e
        event.respond "The user you are trying to kick has a role higher than/equal to me. If you believe this is a mistake, report this to the CB Server"
        bot.send_message(281280895577489409, "ERROR on server #{event.server.name} (ID: #{event.server.id}) for command `A^kick`, `#{e}`")
      else
        event.respond "Sorry, but I do not have the \"Kick Members\" permission"
      end
    else
      event.respond "Sorry, but you need to mention the person you want to kick"
    end
  end
  bot.send_message(281280895577489409, "^kick | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:ping, help_available: false, max_args: 0, usage: 'A^ping') do |event|
  m = event.respond('Pinging!')
  m.edit "Pong! Hey, that took #{((Time.now - event.timestamp) * 1000).to_i}ms."
  bot.send_message(281280895577489409, "^ping | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command([:eightball, :eball, :'8ball'], help_available: false, min_args: 1, usage: 'A^8ball <words>', bucket: :normal, rate_limit_message: 'Even the 8ball needs a break... (`%time%` seconds left)') do |event|
  event.respond ["Sources say... Yeah", "Sources say... Nah", "Perhaps", "As I see it, yes", "As I see it, no", "If anything, probably", "Not possible", "Ask again at a later time", "Say that again?", "lol idk", "Probably not", "woahdude", "[object Object]", "Undoubtfully so", "I doubt it", "Eh, maybe"].sample
  bot.send_message(281280895577489409, "^eightball | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:roll, help_available: false, max_args: 0, usage: 'A^roll', bucket: :normal, rate_limit_message: 'There\'s no way you can roll a die that fast (`%time%` seconds left)') do |event|
  h = event.respond '**Rolling Dice!**'
  sleep [1, 2, 3].sample
  h.edit "And you got a... **#{rand(1..6)}!**"
  bot.send_message(281280895577489409, "^roll | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:flip, help_available: false, max_args: 0, usage: 'A^flip', bucket: :normal, rate_limit_message: 'There\'s no way you can flip a coin that fast (`%time%` seconds left)') do |event|
  m = event.respond '**Flipping Coin...**'
  sleep [1, 2, 3].sample
  m.edit ["woahdude, you got **Heads**", "woahdude, you got **Tails**", "You got **heads**", "You got **tails**"].sample
  bot.send_message(281280895577489409, "^flip | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:flop, help_available: false, max_args: 0, usage: 'A^flop', bucket: :normal, rate_limit_message: 'There\'s no way you can coin a fast that flop (`%time%` seconds left)') do |event|
  m = event.respond ["Oops, the coin flipped so high it didn't come back down", "The coin multiplied and landed on both", "The coin... disappeared", "Pong! It took **#{((Time.now - event.timestamp) * 1000).to_i}ms** to ping the coin", "And you got a... **#{rand(1..6)}!** wait thats not how coins work", "Perhaps you could resolve your situation without relying on luck", "noot", "[Witty joke concerning flipping a coin]", "[BOTTOM TEXT]"].sample
  bot.send_message(281280895577489409, "^flop | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:info, help_available: false, max_args: 0, usage: 'A^info') do |event|
  event << "***Info About CahBot:***"
  event << ""
  event << "**What is CahBot/CahBot Alpha?** CB is a small Discord bot with loads of potential, Alpha is the super-duper-ultra-mega borderline experimental version."
  event << "**Who made CahBot?** Cah#5153 coded CahBot, with help from happyzachariah#6121 and others"
  event << "**Why does CahBot exist?** One day I was bored so I made a Discord bot. End of story kthxbai"
  event << "**Does CahBot have a server or something?** You bet, https://goo.gl/02ZRK5"
  event << "**u suk a bunnch an u can hardly mak a disc cord bawt.** Radical, thank you for noticing"
  bot.send_message(281280895577489409, "^info | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:trello, help_available: false, max_args: 0, usage: 'A^trello') do |event|
  event.respond "The Trello board for CahBot: https://goo.gl/QNJa3E"
  bot.send_message(281280895577489409, "^trello | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.message(with_text: 'CBA prefix') do |event|
  event.respond "My prefix is `A^`. For help, do `A^help`"
  bot.send_message(281280895577489409, "\"CBB Prefix\" | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:rnumber, help_available: false, min_args: 2, max_args: 2, usage: 'A^rnumber <small num> <large num>') do |event, min, max|
  rand(min.to_i .. max.to_i)
  bot.send_message(281280895577489409, "^rnumber | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:invite, help_available: false, max_args: 0, usage: 'A^invite') do |event|
  event.respond "To invite me to your server, head over here: https://goo.gl/rBpKGh"
  bot.send_message(281280895577489409, "^invite | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:say, help_available: false, required_permissions: [:manage_messages], min_args: 1, permission_message: "Sorry, you need the Manage Messages perm in order to use A^say", usage: 'A^say <words>') do |event, *args|
  event.message.delete
  event << "#{args.join(" ")}"
  bot.send_message(281280895577489409, "^say | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command([:reverse, :rev], help_available: false, min_args: 1, usage: '>sdrow< esrever^B') do |event, *args|
  "#{args.join(' ')}".reverse
  bot.send_message(281280895577489409, "^reverse | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:userinfo, help_available: false, max_args: 0, usage: 'A^userinfo') do |event|
  event << "**__User Info For You (in the works still)__**"
  event << ""
  event << "**User ID:** `#{event.user.id}`"
  event << "**User Discrim:** `#{event.user.discrim}`"
  event << "**Username:** `#{event.user.name}`"
  event << "**True or False: Are You A Bot?** `#{event.user.current_bot?}`"
  event << "**User Nickname** `#{event.user.nick}`"
  event << "**User Avatar (may be wrong due to gif avatars):** https://discordapp.com/api/v6/users/#{event.user.id}/avatars/#{event.user.avatar_id}.jpg"
  bot.send_message(281280895577489409, "^userinfo | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:thanks, help_available: false, max_args: 0, usage: 'A^thanks') do |event|
  event << "Thanks so much to these current Donors:"
  event << "ChewLeKitten#6216 - Cool Donor, Contributor, and an ultra-rad person"
  puts "^thanks | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})"
end

bot.command(:update, help_available: false, max_args: 0, usage: 'A^update') do |event|
  event << '**Latest CahBot Alpha Update**'
  event << ''
  event << 'Just created Alpha, woot'
  bot.send_message(281280895577489409, "^update | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command([:servercount, :servcount], help_available: false, max_args: 0, usage: 'A^servercount') do |event|
  event.respond "CahBot Alpha is on **#{bot.servers.count}** servers as of now"
  bot.send_message(281280895577489409, "^servercount | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:donate, help_available: false, max_args: 0, usage: 'A^donate') do |event|
  event.respond "Hi #{event.user.name}, click here for donations: <https://goo.gl/QBvB7N> ~~*not a virus i swear*~~"
  bot.send_message(281280895577489409, "^donate | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:help, help_available: false, max_args: 0, usage: 'A^help') do |event|
  event << ' woahdude, you looking for help? Well, here\'s what you need to know.'
  event << ' For a list of commands, you can do `A^cmds`, for info about CahBot, do `A^info`'
  bot.send_message(281280895577489409, "^help | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:noot, help_available: false, max_args: 0, usage: 'A^noot') do |event|
  event.respond "NOOT https://s-media-cache-ak0.pinimg.com/originals/fe/cb/80/fecb80585eca20163a4d57fa281610b8.gif"
  bot.send_message(281280895577489409, "^noot | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command([:cmds, :commands], chain_usable: false, max_args: 0, usage: 'A^commands') do |event|
  event << 'Here are all of my commands for you to use!'
  event << '*__Cah\'s Commands__*'
  event << '`A^restart`: Pulls that fresh code and runs it, provided we don\'t run into a syntax error or anything'
  event << '`A^die`: Kills the bot, without pulling any code or anything'
  event << '`A^eval`: Like you don\'t know what eval commands do'
  event << '`A^set <avatar|username|game|status> <args>`: Sets stuff'
  event << ''
  event << '*__Moderation Commands (in the works)__*'
  event << '`A^ban <mention>`: Bans the user mentioned and deletes the past 7 days of messages from them'
  event << '`A^kick <mention>`: Kicks the user mentioned (A bit bugged, working on it)'
  event << '`A^say`: Makes CBB say something, you need the manage messages perm tho ~~yes I know it\'s not much of a moderation command shut up~~'
  event << ''
  event << '*__Fun Commands/Other Commands/Things I Was Too Lazy To Group__*'
  event << '(upon saying "CBA prefix") reminds you the prefix'
  event << '`A^info`: Shows you some info about CB, or something'
  event << '`A^rnumber <Number> <Other Number>`: Gives you a random number'
  event << '`A^help`: Basically tells you to go here'
  event << '`A^cmds`: pulls up this'
  event << '`A^eightball`: Ask the 8ball something'
  event << '`A^userinfo`: Shows some info about you'
  event << '`A^reverse`: Reverses text'
  event << '`A^flip`: Flips a coin, what else did you expect?'
  event << '`A^flop`: Flops a coin, what expect did you else?'
  event << '`A^ping`: Used to show response time'
  event << '`A^servercount`: Returns the number of servers CB is in'
  event << '`A^invite`: Gives you a link to invite me to your own server!'
  event << '`A^roll`: Rolls a number between 1 and 6'
  event << '`A^donate`: Want to donate? That\'s great! This command gives you a link for Patreon donations'
  event << '`A^update`: Gives you the latest CB update'
  event << '`A^feedback <words>`: Sends your feedback to the CB Server'
  event << '`A^thanks`: Thanks to these radical donors!'
  event << '`A^trello`: The Trello board, woahdude'
  event << '`A^noot`: noot (don\'t ask I didn\'t write this)'
  event << ''
  event << 'As always, if you find a horrible bug, report it in the CB Server <https://goo.gl/02ZRK5>'
  bot.send_message(281280895577489409, "^commands | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
end

bot.command(:feedback, min_args: 1) do |event, *args|
  if event.channel.pm? == true
    bot.send_message(252239053712392192, "New Feedback from `#{event.user.name}`\##{event.user.discriminator}. ID: #{event.user.id}. From a DM.

*#{args.join(' ')}*")
    m = (event.respond "Radical! Feedback sent.")
    sleep 5
    m.delete
    bot.send_message(281280895577489409, "^feedback | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) in a DM")
  else
    event.message.delete
    bot.send_message(252239053712392192, "New Feedback from `#{event.user.name}`\##{event.user.discriminator}. ID: #{event.user.id}. From the land of `#{event.server.name}` (Server ID: #{event.server.id}).
*#{args.join(' ')}*")
    m = (event.respond "Radical! Feedback sent.")
    bot.send_message(281280895577489409, "^feedback | Command ran by #{event.user.name}\##{event.user.discriminator} (ID: #{event.user.id}) on server #{event.server.name} (ID: #{event.server.id})")
    sleep 5
    m.delete
  end
end

bot.run :async

bot.send_message(287050338144616449, "Restarted/Booted successfully")

bot.sync
