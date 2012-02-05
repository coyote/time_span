#require "time_span/version"

module TimeSpan

  class TimeSpan

    attr_accessor :starts, :ends     # RelativeTime objects

    ##################################
    ## time comparison               #
    ##################################

    def initialize(starting_at, ending_at)
      raise "Cannot make a span unless both points are on the same timeline" unless  starting_at.colinear_with?(ending_at)
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

    def != (b)
      !end_with(b) || !starts_with(b)
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
  #
  class TimeLine <  Array

    attr_accessor :line, :indices_of, :name

    def to_s
      name.to_s
    end

    def initialize(name="")
      @name = name
      @line = []
      @indices_of = {}
    end

    def position_of(obj)
      @indices_of[obj]
    end

    def append(obj)
      insert_at(@line.size, obj)
    end

    def increase_after(pos, by=1)
      @indices_of.each_key do |key|
        @indices_of[key] += by if (@indices_of[key] >= pos)
      end
    end

    def append_to_next(relative_obj, obj, relative=1)
      insert_at(position_of(relative_obj)+relative, obj)
    end

    def insert_before_next(relative_obj, obj, relative_offset=1)
      relative_position = position_of(relative_obj)
      increase_after(relative_position + relative_offset, relative_offset)
      @line[relative_position + relative_offset,0] = nil
      insert_at(relative_position+relative_offset, obj)
    end

    ## needs work for RelativeTime objects
    def insert_at(pos, obj)

      raise "can only add a time to its own timeline" unless obj.timeline.equal? self
      if @line[pos].nil?
        @line[pos] = [obj]
        @indices_of[obj] = pos
      else
        op = @line[pos].kind_of?(Array) ? '<<'  : '='
        @line[pos].send(op.to_sym, obj) unless @line[pos].include?(obj)  # no dupliates
        @indices_of[obj] = pos                                           # dup overwrites
      end
    end

    def remove(obj)
      # cannot remove [] or the @indices_of will be wrong
      # call to #compress to remove the extra []s
      pos =  position_of(obj)

      if pos                        # do nothing if it isn't there'
        @line[pos].delete(obj)
        @indices_of.delete(obj)
      end

    end

    ## removes all [] elements, and decrements accordingly the @indices_of
    ##  ideally this should be transactional

    def compress!

      mod_level = 0
      offsets = []
      0.upto(line.size-1) do |i|
        mod_level -= 1 if @line[i].empty?
        offsets << mod_level
      end

      ## poor man's transaction.  Don't do directly on indices_of so less chance of interruption
      indices = indices_of

      ## refactor to use increase_after
      indices.each_key do |key|
        indices[key] = indices[key] + offsets[indices[key]]
      end

      indices_of = indices
      @line.delete([])
    end

  end

  ###########################################################################################
  #                                                                                         #
  # A relative time must be able to be have equal times                                     #
  # implemented as an Array of Arrays; all elements of the 'subarray' are equal in time,    #
  # otherwise, the time relationship are based on position in the main array                #
  #                                                                                         #
  # diff cannot be done, it makes no sense, due to the fuzziness                            #
  #                                                                                         #
  #  RelativeTime must be within a TimeLine                                                 #
  ###########################################################################################

  class RelativeTime

    attr_accessor  :timeline, :reference_to    # reference_to should respond_to? :to_s

    # create a realtive time *within a timeline*  after position
    def initialize  tline, ref
       @timeline= tline
       @reference_to= ref
    end

    def to_s
      reference_to.to_s
    end

    ## any method on fixnum with 1 RelativeTime param can be in the list below
    %w{< <= == != >= >}.each{ |meth|
      self.send(:define_method, meth) {|b|
        raise "can only compare to other times on the same timeline." unless valid_and_comparable_with?(b)     # can NOT compare across TimeLines
        self.timeline.position_of(self).send(meth, b.timeline.position_of(b))
      }
    }

    def positioned?
      self.timeline.indices_of.keys.include?(self)
    end

    def colinear_with?(b)
      self.timeline.equal?(b.timeline)
    end


    protected

    def valid_and_comparable_with?(b)
      !self.timeline.nil? && !b.timeline.nil?  &&  colinear_with?(b)
    end


  end

end
