require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "TimeSpan" do

  let(:timeline) do
    TimeSpan::TimeLine.new  "test timeline"
  end

  let (:time_a) do
    TimeSpan::RelativeTime.new timeline, "Some timepoint a"
  end

  let (:time_b) do
    TimeSpan::RelativeTime.new timeline, "Some timepoint b"
  end

  let (:time_c) do
    TimeSpan::RelativeTime.new timeline, "Some timepoint c"
  end

  let (:time_d) do
    TimeSpan::RelativeTime.new timeline, "Some timepoint d"
  end

  let (:time_span) do
    TimeSpan::TimeSpan.new(time_a, time_c, timeline, "testing time span")
  end


  before(:each) do
    timeline.append time_a
    timeline.append time_b
    timeline.append time_c
    timeline.spans <<  time_span
  end

  context "TimeSpan::TimeLine" do

    context "instance methods" do

      context "cloning" do
        it "should raise a NotImplementedError" do
          lambda {
             timeline.clone }.should raise_error NotImplementedError
        end
      end

      context "equality comparator" do

        ## two timelines are equal only if names are the same and they are empty.
        it "should return == when all values are equal" do
          timeline2 = TimeSpan::TimeLine.new "testing equality."
          timeline3 = TimeSpan::TimeLine.new "testing equality."
          timeline2.should == timeline3 #, "Not returning == when they are."
        end

        it "should return equal if all values are equal." do
          timeline2 = TimeSpan::TimeLine.new "testing equality."
          timeline3 = TimeSpan::TimeLine.new "testing equality."
          relativet = TimeSpan::RelativeTime.new timeline2, "Some time point."
          timeline2.append relativet
          timeline2.should_not == timeline3
        end

      end

      context "statues" do

        it "should have non-empty endpoint statuses" do
          timeline.all_endpoint_statuses.should_not be_empty
        end

        it "should get all the endpoint statuses" do
          timeline.all_endpoint_statuses.should ==  {time_span => [time_span.starts.reference_to, time_span.ends.reference_to]}
        end

        it "knows the statuses for all associated TimeSpan objects" do
          timeline.all_relative_time_statuses.sort.should == ["Some timepoint a", "Some timepoint b", "Some timepoint c"]
        end

      end

      context "spans" do
        it "the TimeLine knows its TimeSpan list" do
          timeline.spans.should include(time_span)
        end
      end

      context "insertion"  do

        it "inserts a TimeSpan::RelativeTime into the timeline." do
          timeline.line.should_not be_empty
        end

        it 'populates the indices_of as well' do
           timeline.indices_of.should_not be_empty
        end

        it "won't insert into the wrong timeline" do
          timeline_b = TimeSpan::TimeLine.new "Another Timeline"
          lambda {
          timeline_b.append(time_a) }.should raise_error ArgumentError
        end

        it "populates the index hash"  do
          timeline.indices_of.should_not be_empty
        end

        it "appends to the next element if it exists" do
          timeline.append_to_next time_a, time_d
          timeline.line.should  ==  [[time_a], [time_b, time_d], [time_c]]
        end

        it "inserts after and creates if element does not exist" do
          timeline.append_to_next time_c, time_d
          timeline.line.should ==  [[time_a], [time_b], [time_c], [time_d]]
        end

        it "inserts after a given time with insert_next" do
          timeline.insert_before_next time_a, time_d
          timeline.line.should ==  [[time_a], [time_d], [time_b], [time_c]]
        end

        it "should adjust the indices when inserting next" do
          timeline.insert_before_next time_a, time_d
          timeline.indices_of[time_b].should == 2
        end

      end

      context "appending" do

        it "appends to the timeline" do
          timeline.append time_d
          timeline.indices_of[time_d].should == 3
        end

        it "has only one RelativeTime after appending to an empty timeline" do
          timeline.append time_d
          timeline.line.size.should be(4)
        end

      end

      context "finding" do

        it "finds an inserted time_span" do
          timeline.position_of(time_b).should == 1
        end

      end

      context "removal" do

        it "removes the content with #remove(obj)"  do
          timeline.remove time_b
          timeline.position_of(time_b).should be_nil
        end

        it "removes from the index as well" do
          timeline.remove time_b
          timeline.indices_of[time_b].should be_nil
        end

        it "does nothing when asked to remove a non-existent object" do
          lambda { timeline.remove(time_d)}.should_not change(timeline, :indices_of)
        end

      end

      context "compression" do

        it "returns identity when compressing full timeline" do
          timeline.compress!
          timeline.line.size.should be 3
        end

        it "does not remove from index position when not compressing" do
          timeline.remove time_b
          timeline.indices_of[time_c].should == 2
        end

        it "removes from the index when compressing" do
          timeline.remove time_b
          timeline.compress!
          timeline.indices_of[time_c].should == 1
        end

        it "removes content positions from the timeline when compressing" do
          timeline.remove time_b
          timeline.compress!
          timeline.line.should == [[time_a], [time_c]]
        end

      end

      context "finding position" do

        it "returns the position of a RelativeTime" do
          timeline.position_of(time_b).should == 1
        end

      end

    end

  end

  context "TimeSpan::TimeSpan" do

    context "instance methods" do

      context "creation" do

        it "should raise an error when trying to clone." do
          lambda {
             time_span.clone }.should raise_error NotImplementedError
        end

        it "should have a timeline associated" do
          timeline.spans.should_not be_empty
        end

        it "should not allow creation when RelativeTime elements which are not on the same TimeLine" do
          other_timeline = TimeSpan::TimeLine.new "another timeline"
          time_other = TimeSpan::RelativeTime.new other_timeline, "Time on other timeline"
          lambda {
            TimeSpan::TimeSpan.new(time_a, time_other)
          }.should raise_error ArgumentError
        end

      end

      context "relative status methods" do

        it "should get the relative statuses for the endpoints" do
          time_span.endpoint_statuses.should == { time_span => [time_a.reference_to, time_c.reference_to]}
        end

      end


      context "single time point comparators" do

        context "same end time, time_span starts before other time_span" do

          let (:time_span_2) do
            TimeSpan::TimeSpan.new(time_b, time_c, timeline)
          end

          it "start before other time_span" do
            time_span.should be_starts_before(time_span_2)
          end

          it "end with other time_span" do
            time_span.should be_ends_with(time_span_2)
          end

          it "not start after other time_span" do
            time_span.should_not be_starts_after(time_span_2)
          end

          it "not start with other time_span" do
            time_span.should_not be_starts_with(time_span_2)
          end

          it "not end before other time_span" do
            time_span.should_not be_ends_before(time_span_2)
          end

          it "end after other time_span" do
            time_span.should_not be_ends_after(time_span_2)
          end

          it "end before other time_span starts" do
            time_span.should_not be_ends_before_other_starts(time_span_2)
          end

          it "end as other time_span starts" do
            time_span.should_not be_ends_as_other_starts(time_span_2)
          end

          it "start after other time_span ends" do
            time_span.should_not be_starts_after_other_ends(time_span_2)
          end

          it "start as other time_span ends" do
            time_span.should_not be_starts_as_other_ends(time_span_2)
          end

        end

      end

      context "time span comparators" do

        let (:time_d) do
          TimeSpan::RelativeTime.new timeline, "Some timepoint d"
        end

        let (:time_e) do
          TimeSpan::RelativeTime.new timeline, "Some timepoint e"
        end

        before(:each) do
          timeline.append time_a
          timeline.append time_b
          timeline.append time_c
          timeline.append time_d
          timeline.append time_e
        end

        let (:time_span_mid) do
          TimeSpan::TimeSpan.new(time_b, time_c, timeline)
        end

        let(:time_span_all) do
          TimeSpan::TimeSpan.new(time_a, time_e, timeline)
        end

        let (:time_span_last) do
          TimeSpan::TimeSpan.new(time_d, time_e, timeline)
        end

        it "identical start and end times should return == as true" do
          time_span_3 = TimeSpan::TimeSpan.new(time_a, time_c, timeline)
          time_span.should == time_span_3
        end

        it "any differences should return not equal" do
          time_span_all.should_not == time_span               # end times differ
        end

        it "time_span ends before time_span_last starts, should return time_span < time_span_last" do
          time_span.should < time_span_last
        end

        it "time_span starts after time_span_last ends, should return time_span_last > time_span" do
          time_span_last.should > time_span
        end

        it "time_span starting after and ending before time_span_mid should be contained inside time_span_mid" do
          time_span_mid.should be_contained_fully_inside(time_span_all)
        end

        it "time_span starting with time_span_all but ending before, is contained inside" do
          time_span.should be_contained_inside(time_span_all)
        end

        it "time_span starting before and ending after time_span_full contains time_span_mid" do
          time_span_all.should be_contains_fully(time_span_mid)
        end

        it "time_span starting before but ending with time_span_mid should contain time_span_mmid" do
          time_span.should be_contains(time_span_mid)
        end

      end

    end

  end

  context "TimeSpan::RelativeTime" do

    context "instance methods" do

      ## comparators make sense only in TimeLine context, not tested here.

      let (:timeline) do
        TimeSpan::TimeLine.new "Some timeline"
      end

      let (:time) do
        TimeSpan::RelativeTime.new timeline, "time point"
      end

      it "raises an error when trying to clone" do
        lambda {
           time.clone }.should raise_error NotImplementedError
      end

      it "returns a string if using '.to_s'" do
        time.to_s.should == 'time point'
      end

      it "is not positioned if not appended" do
        time.should_not be_positioned
      end

      it 'is positioned once appended.' do
        timeline.append time
        time.should be_positioned
      end

    end

  end

end
