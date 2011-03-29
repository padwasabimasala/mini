require 'dm-core'
require 'ostruct'

module Mini
  #DataMapper::Logger.new($stdout, :debug)
  DB_CONFIG = YAML.load_file(File.join(MINI_ROOT, '/config/database.yml'))
  attrs = OpenStruct.new(DB_CONFIG[Mini.env])
  if attrs.adapter.nil?
    msg = "No DataMapper config for Mini.env #{Mini.env}!"
    warn(msg)
    Mini.log.warning msg
  else
    uri = "#{attrs.adapter}://#{attrs.username}:#{attrs.password}@#{attrs.host}/#{attrs.database}"
    DataMapper.setup(:default, uri)
  end
end
