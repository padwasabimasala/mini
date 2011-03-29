require File.join(File.dirname(__FILE__), 'boot') if !defined? MINI_ROOT

Mini::Initializer.run do |config|
  config.deploy_path = '/var/www/apps/mini/current'
  if Mini.env =~ /micro/
    config.amazon_crawler_count = 2
    config.facebook_crawler_count = 2
    config.flickr_crawler_count = 2
    config.myspace_crawler_count = 2
    config.tagged_crawler_count = 2
    config.twitter_crawler_count = 2
  end
end
