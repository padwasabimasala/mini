if `uname -s`.strip == "Linux"
  config.amazon_crawler_count   = 18
  config.facebook_crawler_count = 18
  config.flickr_crawler_count   = 2
  config.myspace_crawler_count  = 14
  config.tagged_crawler_count   = 1
  config.twitter_crawler_count  = 20
  config.crawl_rate = 1_050_000
end
