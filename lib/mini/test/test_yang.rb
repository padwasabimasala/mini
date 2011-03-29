require File.dirname(__FILE__) + '/setup'
require 'mini/util/yang'

module Mini::Util
  class YangTest < Test::Unit::TestCase
    def test_each
      ranges = []
      Yang.new(0,20,10).each do |min, max|
        ranges << [min, max]
      end
      assert_equal([[0,9], [10,19], [20,20]], ranges)
    end
  end
end
