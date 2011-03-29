require 'net/smtp'
require 'socket'
require 'shout-bot'

module Mini
  class Notifier
    def self.send(subject, message, to=["mb@globalbased.com"])
      from = 'notifications@miningbased.com'
      host = Socket.gethostname
      subject = "Mini Notification #{subject}"

      email =  "From: <#{from}>\n"
      email += "To: #{to.map{|a| "<#{a}>"}.join(", ")}\n"
      email += "Subject: #{subject} - from host #{host}\n\n"
      email += "#{message}"

      Net::SMTP.start("smtp.globalbased.com") do |smtp|
        smtp.send_message(email, from, to)
        smtp.finish
      end
    end

    def self.irc(subject, message)
      ShoutBot.shout('irc://mini-bot@admin.miningbased.com/#mb') do |channel|
        channel.say("%s: %s" % [subject, message])
      end
    end

  end
end

