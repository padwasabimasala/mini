require File.dirname(__FILE__) + '/setup'

require 'mini/file_cache'
require 'tempfile'

class TestFileCache < Test::Unit::TestCase
  def setup
    @file = Tempfile.new("file_cache_test")
    @cache = Mini::FileCache.new(@file.path)
    assert(File.exists?(@file.path))
  end

  def test_appending_and_reading
    test_hsh = {:hello => 'world'}
    @cache << test_hsh
    assert_equal(test_hsh, @cache.records.first)
  end

  def test_appending_raises_error
    assert_raise(StandardError) do
      @cache << "Hello World"
    end
  end
end
