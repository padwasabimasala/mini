require 'daemons'

module Daemons
  class Application
    def output_logfile; "#{MINI_ROOT}/#{@name}.output_log"; end
  end
end

class Mini::Daemonizer
  def self.run(name)
    @name = name
    Daemons.run_proc(name, :log_ouput => true, :hard_exit => true) { yield }
  end
end
