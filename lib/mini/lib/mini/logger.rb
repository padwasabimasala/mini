require 'logger'
require 'msg'

# Mini Logger Example
# =================== 
#
# Log a message
# -------------
#
#   Mini.log.err "I will go down with this ship"
# 
#   Dido:
#
#   Mini::Logger.log.err "I won't put my hands up and surrender"
#
# In either case the message gets logged to: 
#  
#   /var/log/user.log #if you understand syslog you may be able to change this behavior, see /etc/syslog.conf for details
#
# Set a process specific log file
# -------------------------------
#
#   Mini::Logger.extra_log = "#{MINI_ROOT}/log/my_crawler.log"
#
#   # And then log like normal
#   Mini.log.err "There will be no white flag above my door"
#
# Log Level
# ---------
#
# The default log level is err. To change it:
#   
#   Mini.log.level = :debug
#   
#   or see the LOG_LEVEL special option below.
#   
# Logging Exceptions
# ------------------
#
# Mini Logger has a special method for logging exceptions which
# which logs a nicely formatted err message, with the backtrace,
# all on one line.
#
#   begin
#     Timeout::timeout(120) {download_page(url)}
#   rescue Timeout::Error => excp
#     Mini.log.excp(excp)
#   end
#
# Special Options
# ---------------
# 
# Mini Logger has a few special options it gets from its 
# environment. To take advantage of them either export them
# in your shell or set them in ENV.
#
# LOG_LEVEL 
#   
#   Overrides all other log level settings. Should be set to 
#   symbol or string value, e.g. :debug or 'info'
#
# LOG_TO_CONSOLE
# 
#   Puts log messages on STDERR. Must be set before the logger
#   is instanciated. That means either in your shell, or before
#   config/env.rb is loaded.
#
# LOG_PUTS_BACKTRACE
#
#   Puts a multiline backtrace to STDERR whenever log_excp is
#   called.
#

require 'active_support' 
# see 
#active_support/core-ext/logger.rb
#active_support/buffered_logger.rb
module ActiveSupport::BufferedLogger::Severity
  constants.each {|c|remove_const(c.to_sym)}
  DEBUG   = 0
  INFO    = 1
  NOTICE  = 2
  WARNING = 3
  ERR     = 4
  CRIT    = 5
  ALERT   = 6
  EMERG   = 7
end

class ActiveSupport::BufferedLogger
  Severity.constants.each do |severity|
    class_eval <<-EOT, __FILE__, __LINE__ + 1
      def #{severity.downcase}(message = nil, progname = nil, &block)  # def err(message = nil, progname = nil, &block)
        add(#{severity}, message, progname, &block)                    #   add(ERR, message, progname, &block)
      end                                                              # end
                                                                       #
      def #{severity.downcase}?                                        # def err?
        #{severity} >= @level                                          #   ERR >= @level
      end                                                              # end
    EOT
  end
end


module Mini
  class LogAdapter < ActiveSupport::BufferedLogger
    DEFAULT_LOG_LEVEL = ERR

    def initialize(file, level)
      super(file, 'daily')
      self.level=( level )
      self
    end

    def add(severity, message, progname = nil, &block)
      msg =  "%6s [%7s] [%s] %s \n" % [$$, severity.to_s.downcase, Time.now.strftime("%a %b %d %H:%M:%S %G"), message]
      super(severity, msg, progname, &block)
    end

    def severity_lookup(severity)
      return severity if severity.class == Fixnum
      sev =  self.class.const_get(severity.to_s.upcase)
      return sev || DEFAULT_LOG_LEVEL
    end

    def level=(_level)
      super(severity_lookup(_level))
    end

    def level
      l = super
      Severity.constants.find { |c| Severity.const_get(c)==l }.downcase.to_sym
    end

  end
end

module Mini
  require 'syslog'
  class SyslogAdapter 
    include Syslog
    DEFAULT_LOG_LEVEL = LOG_ERR
    FACILITY = 'mini'
    def initialize(_level)
      open(FACILITY) unless opened?
      self.level=(_level)
      return self
    end

    def severity_lookup(severity)
      return severity if severity.class == Fixnum
      severity_name = "log_#{severity}".upcase
      return self.class.const_get(severity_name) ||  DEFAULT_LOG_LEVEL
    end
   
    #mask => level
    MAPPING = {
      1 => :emerg,
      3 => :alert,
      7 => :crit,
      15 => :err,
      31 => :warning,
      63 => :notice,
      127 => :info,
      255 => :debug
    }

    def level
      MAPPING[mask]
    end

    def level=(_level)
      sev = severity_lookup(_level)
      self.mask=( LOG_UPTO( sev ) )
    end
  end
end

module Mini
  module Logger
    DEFAULT_LOG_LEVEL = :err

    class DualLogger
      attr_accessor :process_name
      attr_accessor :properties

      def initialize(level)
        @logs = {
          :default => Mini::SyslogAdapter.new(level)
        }
        @logs[:console] = ::Mini::LogAdapter.new(STDERR,level) if ENV['LOG_TO_CONSOLE']
        @properties = {}
      end

      def extra_log=(file)
        @logs[:extra] ||= ::Mini::LogAdapter.new(file, @logs[:default].level)
      end

      def level=(_level)
        @logs.each {|name, log| log.level = _level }
      end

      ActiveSupport::BufferedLogger::Severity.constants.each do |severity|
        sev = severity.downcase
        define_method(sev.to_sym ) do |msg|
          fmt_msg = format_msg(msg, sev)
          @logs.each {|name, log| log.send(sev, fmt_msg)}
        end                                          
      end
      
      def format_msg(msg, severity)
        props = []
        properties.each {|k,v| props << "#{k}:#{v.respond_to?(:call) ? v.call : v.to_s}"} 
        msg = "[mini:%s:%s] %-7s: %s (in %s) {%s} " % [Mini.env, process_name, severity.upcase, msg.to_s.gsub('%', '%%'), caller[1], props.join(' ')]
      end

      def process_name
        @process_name || :undefined
      end

      def err(msg)
        # what is the point of this queue?
        fmt_msg = format_msg(msg, 'ERR')
        Msg::Queue.new.produce("errors", fmt_msg)
        @logs.each {|name, log| log.send(:err, fmt_msg)}
      end

      def excp(excp)
        if ENV['LOG_PUTS_BACKTRACE']
          STDERR.puts
          STDERR.puts '-' * 78
          STDERR.puts excp.class
          STDERR.puts excp.message
          STDERR.puts excp.backtrace
          STDERR.puts
          STDERR.flush
        end
        err("Caught Exception (#{excp.class}) #{excp.message} -- Backtrace: #{excp.backtrace}")
      end
    end

    def self.log
      @@logger.level = ENV['LOG_LEVEL'] if ENV['LOG_LEVEL']
      @@logger
    end

    def self.extra_log=(file)
      @@logger.extra_log = file
    end
      
     @@logger = DualLogger.new(DEFAULT_LOG_LEVEL)
  end

end
