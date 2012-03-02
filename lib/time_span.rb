require "time_span/version"

# @author Craig A. Cook
module TimeSpan

  # this class' objects have a starting and ending TimeSpan::RelativeTime, and both times must be on the same TimeSpan::TimeLine
  # implements a large selection of comparators, both for start / end times (single time compartors),
  # and also range comparators
  # @author Craig A. Cook
  class TimeSpan

    # TimeSpan::RelativeTime start time
    attr_accessor :starts
    # TimeSpan::RelativeTime end time
    attr_accessor :ends
    # TimeSpan::TimeLine this TimeSpan is associated with
    attr_accessor :time_line
    attr_accessor :name

    # @param [TimeSpan::RelativeTime] starting_at is when the span starts
    # @param [TimeSpan::RelativeTime] ending_at is when the spa nends
    # @param [TimeSpan::TimeLIne] is the associated TimeLine
    # @param [String] The name of the TimeSpan (Actually any Ruby Object for which '#respond_to?(:to_s) == true')
    # @return [Boolean] true if passed arguments are valid to create a TimeSpan
    def initialize(starting_at, ending_at, t_line, nom="(unnamed)")
      raise ArgumentError, "Cannot make a span unless both points are on the same time_line" unless  starting_at.colinear_with?(ending_at)
      self.starts           = starting_at
      self.ends             = ending_at
      self.time_line        = t_line
      self.time_line.spans  << self
      self.name             = nom
      starting_at.kind_of?(RelativeTime) && ending_at.kind_of?(RelativeTime) && (starting_at <= ending_at)
    end

    # returns the 'statuses' for the start and end times
    # @return start and end time statuses in a hash with key is self
    def endpoint_statuses
      {self => [self.starts.reference_to, self.ends.reference_to]}
    end

  #######################################################################################################
  #                                                                                                     #
  #  single RelativeTime comparators                                                                    #
  #                                                                                                     #
  #######################################################################################################

    # tests  if one TimeSpan starts before another (on the same TimeLine)
    # @param [TimeSpan::TimeSpan] other_time_span the TimeSpan being compared to self
    # @return  true if self starts before b starts
    def starts_before?(other_time_span)
      starts < other_time_span.starts
    end

    # tests  if one TimeSpan starts after another (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self starts after other_time_span starts
    def starts_after?(other_time_span)
      starts > other_time_span.starts
    end

    # tests  if one TimeSpan starts with or after another (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self starts on or after other_time_span starts
    def starts_on_or_after?(other_time_span)
      starts >= other_time_span.starts
    end

    # tests  if one TimeSpan starts at the same time as another (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self starts at the same time as other_time_span starts
    def starts_with?(other_time_span)
      starts == other_time_span.starts
    end

    # tests  if one TimeSpan starts before or at the same time as another (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self starts before or at the same time as other_time_span starts
    def starts_before_or_with?(other_time_span)
      starts <= other_time_span.starts
    end

    # tests  if one TimeSpan ends before another starts (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self ends before another time_span starts
    def ends_before?(other_time_span)
      ends < other_time_span.ends
    end

    # tests  if one TimeSpan end before or at the same time as another ends (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self ends before or at the same time as another time_span ends
    def ends_on_or_before?(other_time_span)
      ends <= other_time_span.ends
    end

    # tests  if one TimeSpan ends after or at the same time as another (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self ends after or at the same time as another time_span ends
    def ends_on_or_after?(other_time_span)
      ends >= other_time_span.ends
    end

    # tests  if one TimeSpan ends after another (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self ends after another time_span ends
    def ends_after?(other_time_span)
      ends > other_time_span.ends
    end

    # tests  if one TimeSpan ends at the same time as another (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self ends at the same time as another time_span ends
    def ends_with?(other_time_span)
      ends == other_time_span.ends
    end

    # tests  if one TimeSpan ends before another starts (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self ends before another time_span starts
    def ends_before_other_starts?(other_time_span)
      ends < other_time_span.starts
    end

    # tests  if one TimeSpan ends at the same time as another starts (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self ends at the same time as another time_span starts (no gap)
    def ends_as_other_starts?(other_time_span)
      ends == other_time_span.starts
    end

    # tests  if one TimeSpan ends at the same time as another (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self ends at the same time as another time_span ends
    def starts_after_other_ends?(other_time_span)
      starts > other_time_span.ends
    end

    # tests  if one TimeSpan starts at the same time as another ends (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self starts at the same time as another time_span ends
    def starts_as_other_ends?(other_time_span)
      starts == other_time_span.ends
    end

    ##################################
    ## span comparison               #
    ##################################

    ## >= and <=  intentionally not defined;
    ##    logically can only mean starts_after? or ends_before? respectively
    ##    which are basically aliased to > & <
    ##    unless it is meant < XOR =


    # tests  if one TimeSpan is the same as another (on the same TimeLine)
    # @param (see #starts_before? )
    # @return [Boolean] true if same as the other
    def == (other_time_span)
      ends_with?(other_time_span) && starts_with?(other_time_span)
    end

    # tests  if one TimeSpan is not the same as another (on the same TimeLine)
    # @param (see #starts_before? )
    # @return [Boolean] true if not same as the other
    def != (other_time_span)
      !end_with(other_time_span) || !starts_with(other_time_span)
    end

    # tests  if one TimeSpan ends before another starts (on the same TimeLine)
    # alias for '#ends_before_other_starts'
    # @param (see #starts_before? )
    # @return [Boolean] true if self ends before another starts
    def < (other_time_span)
      ends_before_other_starts?(other_time_span)
    end

    # tests  if one TimeSpan starts after another ends (on the same TimeLine)
    # alias for '#starts_after_other_ends'
    # @param (see #starts_before? )
    # @return [Boolean] true if self starts after another ends
    def > (other_time_span)
      starts_after_other_ends?(other_time_span)
    end

    # tests  if one TimeSpan is contained within  another  (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self contained inside another
    def contained_fully_inside?(other_time_span)
      starts_after?(other_time_span) && ends_before?(other_time_span)
    end

    # tests  if one TimeSpan is contained within another, possibly begining as or ends as another  (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self contained inside another, including same endpoints
    def contained_inside?(other_time_span)
      starts_on_or_after?(other_time_span) && ends_on_or_before?(other_time_span)
    end

    # tests  if one TimeSpan contains another  (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self contains another
    def contains_fully?(other_time_span)
      starts_before?(other_time_span) && ends_after?(other_time_span)
    end

    # tests  if one TimeSpan contains within  another  (on the same TimeLine)
    # @param (see #starts_before? )
    # @return true if self contains another
    def contains?(other_time_span)
      starts_before_or_with?(other_time_span) && ends_on_or_after?(other_time_span)
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
  # @author Craig A. .Cook
  class TimeLine <  Array

    attr_accessor :line, :indices_of, :name, :spans


    def initialize(name="")
      @name = name
      @line = []
      @indices_of = {}
      @spans = []
    end

    # returns the TimeLine's name
    # @return [String] TimeLine's name'
    def to_s
      name.to_s
    end

    # endpoint statuses for all TimeSpans on the TimeLine, plus TimeLine name
    # @return [String] TimeSpan endpoint statuses + TimeLine name
    def inspect
      line.inspect + name
    end

    # @return [Array] endpoint statuses for all TimeSpan s on the TimeLine
    def all_endpoint_statuses
      spans.inject({}){ |acc, span| acc.merge!(span.endpoint_statuses) }
    end

    ## attached times only (internal API)
    # @return [Array] indices of keys
    def relative_times
      indices_of.keys
    end

    # all statuses on the TimeLine
    # @return [Array] statuses for all attached RelativeTime s on the TimeLine
    def all_relative_time_statuses
      relative_times.inject([]) {|acc, v| acc << v.reference_to }
    end

    ## indices methods

    ## find the position of a RelativeTime on the TimeLine
    # @return [Fixnum] RelativeTime's position on the TimeLine (self)
    def position_of(obj)
      @indices_of[obj]
    end

    # bump up indices after a point, so that a RelativeTime may be inserted
    # @return nil  no return value, helper method to keep data structures up to date.
    def increase_after(pos, by=1)
      @indices_of.each_key do |key|
        @indices_of[key] += by if (@indices_of[key] >= pos)
      end
    end

    ## insertion

    # add to the  end of the TimeLine
    # @param obj object to be inserted into the TimeLine
    # @return (see #insert_at)
    def append(obj)
      insert_at(@line.size, obj)
    end

    # inserts to the end of the relative object's time, becoming equal with it
    # @param  relative_obj object after which to insert  obj
    # @param  obj  object inserted after relative_object
    # @return (see #insert_at)
    def append_to_next(relative_obj, obj, relative=1)
      insert_at(position_of(relative_obj)+relative, obj)
    end

    ## inserts into a new space before the relative object (first parameter)
    # inserts obj before relative_obj by offset
    # @param relative_obj object for computing position where obj is inserted
    # @param the inserted object
    # @return (see #insert_at)
    def insert_before_next(relative_obj, obj, relative_offset=1)
      relative_position = position_of(relative_obj)
      increase_after(relative_position + relative_offset, relative_offset)
      @line[relative_position + relative_offset,0] = nil
      insert_at(relative_position+relative_offset, obj)
    end

    ## place obj at the numbered position
    # @param pos where to insert obj in the TimeLIne
    # @param obj obj inserted into the TimeLIne
    # @return [Fixnum] ]the (relative) position where the object was inserted
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
    # @param obj object to be removed from the TimeLIne
    # @return []nil|Fixnum] position of deleted object
    def remove(obj)
      pos =  position_of(obj)
      if pos                        # do nothing if it isn't there'
        @line[pos].delete(obj)      #  remove from list
        @indices_of.delete(obj)     #  remove from index
      end
    end

    ## removes all [] elements, and decrements accordingly the @indices_of
    ##  ideally this should be transactional
    # @return [nil] cleanup method
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
  #
  # @author Craig A. Cook
  class RelativeTime

    attr_accessor  :time_line       # TimeLine on which this RelativeTime is placed
    attr_accessor   :reference_to    # Object (PORO) reference_to should respond_to? :to_s

    # create a realtive time *within a time_line*  after position
    # @param tline [TimeSpan::TimeLine] TimeLIne on which this RelativeTime is placed
    # @param ref [Object] the object placed on the timeline
    # @return the .to_s of the referenced object
    def initialize  tline, ref
       @time_line= tline
       @reference_to= ref
    end

    # @return [String] the string representation of referenced object
    def to_s
      @reference_to.to_s
    end

    # comparator methods
    # @param [TimeSpan::RelativeTime] other_relative_time time being compared to
    # @return [Boolean] depending on the relationship
    ## any method on fixnum with 1 RelativeTime param can be in the list below
    %w{< <= == != >= >}.each{ |meth|
      self.send(:define_method, meth) {|other_relative_time|
        raise ArgumentError, "can only compare to other times on the same time_line." unless valid_and_comparable_with?(other_relative_time)     # can NOT compare across TimeLines
        self.time_line.position_of(self).send(meth, other_relative_time.time_line.position_of(other_relative_time))
      }
    }

    # @return [Boolean] true if self has been properly placed on a TimeLine
    def positioned?
      self.time_line && self.time_line.indices_of.include?(self)
    end

    # @param [TimeSpan::RelativeTime]  other time to be sure is on self's TimeLIne
    # @return [Boolean] true if both are on the same TimeLine
    def colinear_with?(other_relative_time)
      other_relative_time.kind_of?(self.class) &&  other_relative_time.positioned? && positioned? &&  time_line.equal?(other_relative_time.time_line)
    end


    protected

    # @param [TimeSpan::RelativeTime] RelativeTime to check for comparability with
    # @return [Boolean] true if they can be compared
    def valid_and_comparable_with?(other_relative_time)
      !self.time_line.nil? && !other_relative_time.time_line.nil?  &&  colinear_with?(other_relative_time)
    end


  end

end
