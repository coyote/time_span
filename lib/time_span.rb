#require "time_span/version"

module TimeSpan

  #######################################################################################################
  #    this classes' object have a starting and ending RelativeTime, and both times must be on the same TimeLine
  #
  #    it implements a large selection of comparators, both for start / end times (single time compartors),
  #    and also range comparators
  class TimeSpan

    attr_accessor :starts, :ends, :time_line, :name     # RelativeTime objects

    def initialize(starting_at, ending_at, t_line, nom="(unnamed)")
      raise ArgumentError, "Cannot make a span unless both points are on the same time_line" unless  starting_at.colinear_with?(ending_at)
      self.starts           = starting_at
      self.ends             = ending_at
      self.time_line        = t_line
      self.time_line.spans  << self
      self.name             = nom
      starting_at.kind_of?(RelativeTime) && ending_at.kind_of?(RelativeTime) && (starting_at <= ending_at)
    end

    def endpoint_statuses
      {self => [self.starts.reference_to, self.ends.reference_to]}
    end

  #######################################################################################################
  #                                                                                                     #
  #  single RelativeTime comparators                                                                    #
  #                                                                                                     #
  #######################################################################################################

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
    ##    logically can only mean starts_after? or ends_before? respectively
    ##    which are basically aliased to > & <
    ##    unless it is meant < XOR =


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


  #######################################################################################################
  #  class TimeLine                                                                                     #
  #                                                                                                     #
  #  TimeLine is how RelativeTime objects are related to each other, they have to have the same         #
  #    frame of reference.                                                                              #
  #                                                                                                     #
  #  instance methods:                                                                                  #
  #                                                                                                     #
  #    to_s  -- convenience method to see which object we have                                          #
  #    position_of(obj) -- its location on the TimeLine                                                 #
  #    increase_after(position, amount) -- make room in the index for an insertion                      #
  #    append (obj)  -- add obj to end of the TimeLine                                                  #
  #    append_to_next(relative_object, object, relative) at relative offset to relative_object, put obj #
  #    insert_before_next(relative_object, object, relative) inserts into new time slot relative to relative_object
  #    insert_at(position, object) -- places object at position, appending if equal time exists         #
  #    remove(obj) -- remove object from the TimeLine                                                   #
  #    compress! -- compresses the TimeLine, removing [] and adjusting the index accordingly            #
  #                                                                                                     #
  #######################################################################################################
  class TimeLine <  Array

    attr_accessor :line, :indices_of, :name, :spans

    def to_s
      name.to_s
    end

    def inspect
      line.inspect + name
    end

    def all_endpoint_statuses
      spans.inject({}){ |acc, span| acc.merge!(span.endpoint_statuses) }
    end

    ## attached times only
    def relative_times
      indices_of.keys
    end

    def all_relative_time_statuses
      relative_times.inject([]) {|acc, v| acc << v.reference_to }
    end

    def initialize(name="")
      @name = name
      @line = []
      @indices_of = {}
      @spans = []
    end

    ## indices methods

    def position_of(obj)
      @indices_of[obj]
    end

    def increase_after(pos, by=1)
      @indices_of.each_key do |key|
        @indices_of[key] += by if (@indices_of[key] >= pos)
      end
    end

    ## insertion

    # add to the  end of the TimeLine
    def append(obj)
      insert_at(@line.size, obj)
    end

    # inserts to the end of the relative object's time, becoming equal with it
    def append_to_next(relative_obj, obj, relative=1)
      insert_at(position_of(relative_obj)+relative, obj)
    end

    ## inserts into a new space before the relative object (first parameter)
    def insert_before_next(relative_obj, obj, relative_offset=1)
      relative_position = position_of(relative_obj)
      increase_after(relative_position + relative_offset, relative_offset)
      @line[relative_position + relative_offset,0] = nil
      insert_at(relative_position+relative_offset, obj)
    end

    ## place obj at the numbered position
    def insert_at(pos, obj)
      raise ArgumentError, "can only add a time to its own time_line" unless obj.time_line.equal? self
      if @line[pos].nil?
        @line[pos] = [obj]
      else
        op = @line[pos].kind_of?(Array) ? '<<'  : '='
        @line[pos].send(op.to_sym, obj).uniq!                # no duplicates in same position
        # dup in diff position overwrites below
      end
      @indices_of[obj] = pos
    end

    # cannot remove [] or the @indices_of will be wrong
    # call  #compress to remove the extra []s
    def remove(obj)
      pos =  position_of(obj)
      if pos                        # do nothing if it isn't there'
        @line[pos].delete(obj)      #  remove from list
        @indices_of.delete(obj)     #  remove from index
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
      indices.each_key do |key|
        indices[key] = indices[key] + offsets[indices[key]]
      end
      indices_of = indices
      @line.delete([])
    end

  end

  #######################################################################################################
  # class RelativeTime                                                                                  #
  #                                                                                                     #
  # public methods:                                                                                     #
  #   comparators: < <= == != >= >                                                                      #
  #      work on any two RelativeTime objects on the same TimeLine                                      #
  #   positioned?                                                                                       #
  #      true if a RelativeTime has been put on a TimeLine                                              #                                                                                   #
  #   colinear_with?(RelativeTime.new)                                                                  #
  #      true if both RelativeTime objects are positioned and on same TimeLine                          #
  #                                                                                                     #
  # protected method:                                                                                   #
  #   valid_and_comparable_with?(RelativeTime)                                                          #
  #      true if                                                                                        #
  #                                                                                                     #
  # diff cannot be done, it makes no sense, due to the fuzziness                                        #
  #                                                                                                     #
  #  RelativeTime must be within a TimeLine                                                             #
  #######################################################################################################
  class RelativeTime

    attr_accessor  :time_line, :reference_to    # reference_to should respond_to? :to_s

    # create a realtive time *within a time_line*  after position
    def initialize  tline, ref
       @time_line= tline
       @reference_to= ref
    end

    def to_s
      @reference_to.to_s
    end

    ## any method on fixnum with 1 RelativeTime param can be in the list below
    %w{< <= == != >= >}.each{ |meth|
      self.send(:define_method, meth) {|b|
        raise ArgumentError, "can only compare to other times on the same time_line." unless valid_and_comparable_with?(b)     # can NOT compare across TimeLines
        self.time_line.position_of(self).send(meth, b.time_line.position_of(b))
      }
    }

    def positioned?
      self.time_line && self.time_line.indices_of.include?(self)
    end

    def colinear_with?(b)
      b.kind_of?(self.class) &&  b.positioned? && positioned? &&  time_line.equal?(b.time_line)
    end


    protected

    def valid_and_comparable_with?(b)
      !self.time_line.nil? && !b.time_line.nil?  &&  colinear_with?(b)
    end


  end

end
