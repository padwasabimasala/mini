# run with: god -c /path/to/mongrel.god -D
require File.dirname(__FILE__) + '/env'
require 'network'
require 'socket'
require 'sys_stat'
require 'fileutils'

GOD_ROOT = MINI_ROOT + '/god'
FileUtils.mkdir_p(GOD_ROOT) unless File.exists?(GOD_ROOT)

GOD_PIDS_ROOT = File.join(GOD_ROOT, "pids")
FileUtils.mkdir_p(GOD_PIDS_ROOT) unless File.exists?(GOD_PIDS_ROOT)
God.pid_file_directory = GOD_PIDS_ROOT

GOD_LOG_ROOT = File.join(GOD_ROOT, "log")
FileUtils.mkdir_p(GOD_LOG_ROOT) unless File.exists?(GOD_LOG_ROOT)

HOST = Socket.gethostname

DRONE = %w[drone03 drone04 drone05 drone06 drone07 drone08 drone09 drone10 drone11 drone12]
MICRO = %w[drone01 drone02 stage03]
ADMIN = %w[admin]

def match_host(array)
  yield if array.any? {|a| HOST.include?(a)}
end

def god
  God.watch do |w|
    yield w
    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running = false
      end
    end
  end
end

# Exporter
match_host(ADMIN) do
  raise StandardError.new("You must set MINI_CLIENT before running this process") unless ENV['MINI_CLIENT']
  client = ENV['MINI_CLIENT']
  God.watch do |w|
    w.name  = "exporter"
    w.group = "admin"
    w.env   = {'LOG_LEVEL' => 'debug'}
    w.start = "#{MINI_ROOT}/lib/exporter/bin/export_order --client #{client} --complete-orders"
    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 150.seconds
        c.running  = false
      end
    end
  end
end

# Scheduler
match_host(ADMIN) do
  raise StandardError.new("You must set MINI_CLIENT before running this process") unless ENV['MINI_CLIENT']
  client = ENV['MINI_CLIENT']
  God.watch do |w|
    w.name  = "scheduler"
    w.group = "admin"
    w.env   = {'LOG_LEVEL' => 'debug'}
    w.start = "#{MINI_ROOT}/lib/scheduler/bin/schedule --client #{client}"

    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 150.seconds
        c.running  = false
      end
    end
  end
end

match_host(DRONE) do
  Network::Network.active.each do |network|
    count = network.crawler_count
    puts "Network: #{network}, count: #{count}"
    if count.nil?
      raise "count nil for #{network.to_s} ... set crawl-count in your env"
    end
    (1..count).each do |num|
      god do |w|
        w.name  = "#{network} drone #{num}"
        w.group = "%s_drones" % network.to_s
        w.env   = {'LOG_LEVEL' => 'info'}
        w.start = "nice #{MINI_ROOT}/lib/drone/bin/drone #{network} --loop"
      end
      sleep 0.1
    end
  end
end

match_host(MICRO) do
  Network::Network.active.each do |network|
    count = network.crawler_count
    if count.nil?
      raise "count nil for #{network.to_s} ... set crawl-count in your env"
    end
    (1..count).each do |num|
      god do |w|
        w.name  = "#{network} micro #{num}"
        w.group = network.to_s
        w.env   = {'LOG_LEVEL' => 'info'}
        w.start = "#{MINI_ROOT}/lib/drone/bin/drone #{network} --micro --loop"
      end
   end
  end
en
