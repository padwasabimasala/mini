if `uname -s`.strip == "Linux"
  if `grep -c processor /proc/cpuinfo`.to_i == 2
    config.amazon_crawler_count = 0
    config.facebook_crawler_count = 0 
    config.flickr_crawler_count = 0
    config.myspace_crawler_count = 0
    config.tagged_crawler_count = 0
    config.twitter_crawler_count = 0
  else
    config.amazon_crawler_count   = 10
    config.facebook_crawler_count = 14
    config.flickr_crawler_count   = 1 
    config.myspace_crawler_count  = 3 
    config.tagged_crawler_count   = 1
    config.twitter_crawler_count  = 0
  end
end
