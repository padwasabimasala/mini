require 'rubygems'
require 'fileutils'

begin
  require 'bundler'
  Bundler.setup
rescue LoadError
  STDERR.puts "Error: Bundler gem not found! Try running 'gem install bundler'."
  exit 1
rescue 
  if ENV['FORCE_BUNDLE_LOAD']
    Dir.glob('/usr/share/mini/ruby/1.8/gems/*/lib').each do |dir|
      $LOAD_PATH.unshift(dir)
    end
  else 
    STDERR.puts "Error: Bundler.setup failed! Try running 'bundle install'."
    exit 1
  end
end

mini_root = File.expand_path(File.dirname(__FILE__) + "/..")
MINI_ROOT = mini_root =~ %r{/var/www/apps/mini/release/.*} ? "/var/www/apps/mini/current" : mini_root

if File.exist?("/media/share") && File.exist?("/media/share/.NFS_MOUNT_CHECK")
  SHARE_ROOT = "/media/share"
else
  SHARE_ROOT = MINI_ROOT + '/share'
  FileUtils.mkdir_p SHARE_ROOT
end

Dir.glob("#{MINI_ROOT}/lib/*/lib").each do |dir|
  $LOAD_PATH.unshift(dir)
end

module Mini
  def self.boot!
    require 'mini/initializer' if !defined? Mini::Initializer
  end
end

Mini.boot!
require 'mini'
require 'ap'
