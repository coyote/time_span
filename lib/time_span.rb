#require "time_span/version"
require 'date'

module TimeSpan
    class TimeSpan

    attr_accessor :starts, :ends     # RelativeTime objects

    ##################################
    ## time comparison               #
    ##################################

    def initialize(starting_at, ending_at)
      self.starts = starting_at
      self.ends   = ending_at
      starting_at.kind_of?(RelativeTime) && ending_at.kind_of?(RelativeTime)
    end


    def starts_before?(b)
      starts < b.starts
    end

    def starts_after?(b)
      starts > b.starts
    end

    def starts_on_or_after?(b)
      starts >= b.starts
    end


    def starts_with?(b)
      starts == b.starts
    end

    def starts_before_or_with?(b)
      starts <= b.starts
    end

    def ends_before?(b)
      ends < b.ends
    end

    def ends_on_or_before?(b)
      ends <= b.ends
    end

    def ends_on_or_after?(b)
      ends >= b.ends
    end

    def ends_after?(b)
      ends > b.ends
    end

    def ends_with?(b)
      ends == b.ends
    end

    def ends_before_other_starts?(b)
      ends < b.starts
    end

    def ends_as_other_starts?(b)
      ends == b.starts
    end

    def starts_after_other_ends?(b)
      starts > b.ends
    end

    def starts_as_other_ends?(b)
      starts == b.ends
    end

    ##################################
    ## span comparison               #
    ##################################

    ## >= and <=  intentionally not defined;


    def == (b)
      ends_with?(b) && starts_with?(b)
    end

    def < (b)
      ends_before_other_starts?(b)
    end

    def > (b)
      starts_after_other_ends?(b)
    end

    def contained_fully_inside?(b)
      starts_after?(b) && ends_before?(b)
    end

    def contained_inside?(b)
      starts_on_or_after?(b) && ends_on_or_before?(b)
    end

    def contains_fully?(b)
      starts_before?(b) && ends_after?(b)
    end

    def contains?(b)
      starts_before_or_with?(b) && ends_on_or_after?(b)
    end

  end

  # first implementation is just as DateTime; later add fuzzy  time
  class RelativeTime  < ::DateTime
  end
end
