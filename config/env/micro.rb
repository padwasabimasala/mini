if `uname -s`.strip == "Linux"
  config.amazon_crawler_count = 2
  config.facebook_crawler_count = 2
  config.flickr_crawler_count = 2
  config.myspace_crawler_count = 2
  config.tagged_crawler_count = 2
  config.twitter_crawler_count = 2
end
