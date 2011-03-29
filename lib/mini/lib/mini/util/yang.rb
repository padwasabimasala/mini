module Mini::Util
  class Yang # YetAnotherNumberGenerator
    def initialize(min, max, increment=100)
      @min = min
      @max = max
      @increment = increment
      reset
    end

    def reset
      @range_min = @min
      @range_max = [(@min + @increment - 1), @max].min
    end

    def has_next_range
      @range_min <= @range_max
    end

    def next_range
      r_val = [@range_min, @range_max]
      @range_min += @increment
      @range_max = [@range_max + @increment, @max].min
      return r_val
    end
    
    def each
      while has_next_range
        min, max = next_range
        yield(min, max)
      end
    end
  end
end
