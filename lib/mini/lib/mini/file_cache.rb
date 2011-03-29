require 'json/pure'
require 'time'

class Mini::FileCache
  def initialize(file_path)
    @file_path = file_path
  end

  def symbolize_keys(hsh)
    hsh.inject({}){|h, kv| h[kv.first.to_sym] = kv.last; h}
  end

  def <<(line)
    raise StandardError.new("line must be a Hash") unless line.is_a?(Hash)
    File.open(@file_path, "a") do |f|
      f.puts(line.to_json)
    end
  end

  def records
    @records ||= begin
      lines = IO.readlines(@file_path)
      lines.map! do |line| 
        line = symbolize_keys(JSON.parse(line))
        line[:time] = Time.parse(line[:time]) if line[:time]
        line
      end
      lines.reverse
    end
  end

  def clear
    File.open(@file_path, "w") do |f|
      f.truncate(0)
    end
  end
end
