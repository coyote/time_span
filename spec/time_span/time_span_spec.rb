require File.expand_path(File.dirname(__FILE__) + '../../spec_helper')

describe "TimeSpan" do

  context "TimeSpan" do

    context "instance methods" do

      let (:alpha_start) do
        TimeSpan::RelativeTime.parse("Jan 1, 2007")
      end

      let (:alpha_end) do
       alpha_start + 2000
      end


      let (:alpha) do
        TimeSpan::TimeSpan.new(alpha_start, alpha_end)
      end

      context "single time point comparators" do

        context "same ends time, alpha starts before beta" do

          let (:beta_start) do
            TimeSpan::RelativeTime.parse("Jan 1, 2008")
          end

          let (:beta) do
            TimeSpan::TimeSpan.new(beta_start, alpha_end)
          end

          context "alpha" do

            it "starts before beta" do
              alpha.should be_starts_before(beta)
            end


            it "ends with beta" do
              alpha.should be_ends_with(beta)
            end

          end

          context "alpha does not" do

            it "start after beta" do
              alpha.should_not be_starts_after(beta)
            end

            it "start with beta" do
              alpha.should_not be_starts_with(beta)
            end

            it "end before beta" do
              alpha.should_not be_ends_before(beta)
            end

            it "end after beta" do
              alpha.should_not be_ends_after(beta)
            end

            it "end before beta starts" do
              alpha.should_not be_ends_before_other_starts(beta)
            end

            it "end as beta starts" do
              alpha.should_not be_ends_as_other_starts(beta)
            end

            it "start after beta ends" do
              alpha.should_not be_starts_after_other_ends(beta)
            end

            it "start as beta ends" do
              alpha.should_not be_starts_as_other_ends(beta)
            end

          end

        end

      end

      context "time span comparators" do

        let (:beta_earliest) do
          alpha_start - 1000
        end

        let (:beta_before_alpha_starts) do
          alpha_start - 500
        end

        let (:beta_after_alpha_starts) do
          alpha_start + 500
        end

        let (:beta_before_alpha_ends) do
          alpha_start + 1000
        end

        let (:beta_right_after_alpha_ends) do
          alpha_end + 500
        end

        let (:beta_last) do
          alpha_end + 1000
        end

        it "identical start and end times should return == as true" do
          beta = TimeSpan::TimeSpan.new(alpha_start, alpha_end)
          alpha.should == beta
        end

        it "alpha ends before beta starts, should return alpha < beta" do
          beta = TimeSpan::TimeSpan.new(beta_right_after_alpha_ends, beta_last)
          alpha.should < beta
        end

        it "alpha starts after beta ends, should return alpha > beta" do
          beta = TimeSpan::TimeSpan.new(beta_earliest, beta_before_alpha_starts)
          alpha.should > beta
        end

        it "alpha starting after and ending before beta should be contained inside beta" do
          beta = TimeSpan::TimeSpan.new(beta_earliest, beta_last)
          alpha.should be_contained_fully_inside(beta)
        end

        it "alpha starting with beta but ending before, is contained inside" do
          beta = TimeSpan::TimeSpan.new(alpha_start, beta_last)
          alpha.should be_contained_inside(beta)
        end

        it "alpha starting before and ending after full contains beta" do
          beta = TimeSpan::TimeSpan.new(beta_after_alpha_starts, beta_before_alpha_ends)
          alpha.should be_contains_fully(beta)
        end

        it "alpha starting before but ending with beta should contain beta" do
          beta = TimeSpan::TimeSpan.new(beta_after_alpha_starts, alpha_end)
          alpha.should be_contains(beta)
        end

      end

    end

  end



end