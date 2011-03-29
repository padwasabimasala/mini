require 'yaml'
require 'erb'
require 'mongoid'

module Mini
  MONGOID_CONF = MINI_ROOT + '/config/mongoid.yml'
  conf = YAML.load(ERB.new(File.new(MONGOID_CONF).read).result)
  Mongoid.configure do |config|
    config.from_hash(conf[Mini.env])
  end
end
