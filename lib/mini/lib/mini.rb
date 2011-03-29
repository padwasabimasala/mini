require File.expand_path(File.join(File.dirname(__FILE__), '../../../config/env')) if !defined? MINI_ROOT

module Mini
  autoload :Logger, 'mini/logger'
  autoload :Notifier, 'mini/notifier'
  autoload :BatchingQueue, 'mini/batching_queue'
  autoload :Queue, 'mini/queue'

  MINI_LOG = "/var/log/mini.log"

  class Error < StandardError
  end

  def self.notify(subject, msg)
    Mini::Notifier.send(subject, msg)
  end

  def self.log
    Mini::Logger.log
  end

  def self.banner(msg = "Thank you for running:")
    require 'mini/cloud'
    if msg
      puts ""
      puts msg
      puts ""
    end
    puts cloud
  end
end
