require File.join(File.dirname(__FILE__), *%w[.. lib paddock])

describe Paddock('development') do
  include Paddock

  it "has an environment" do
    Paddock.environment = "development"
    Paddock.environment.should == "development"
  end

  it "raises a FeatureNotFound error when the feature don't not exist none" do
    proc {
      paddock(:raptor_fences)
    }.should raise_error(Paddock::FeatureNotFound)
  end

  describe "defining enabled features" do
    context "when not specifying environments" do
      before(:each) do
        Paddock('development') do
          enable :perimeter_fence
        end
      end

      it "runs the feature block always" do
        called = false
        paddock(:perimeter_fence) { called = true }
        called.should be_true
      end

      it "always returns true on feature check" do
        paddock(:perimeter_fence).should be_true
      end
    end

    context "when specifying environment" do
      before(:each) do
        Paddock('development') do
          enable :perimeter_fence, :in => :development
        end
      end

      context "when in appropriate environment" do
        before(:each) do
          Paddock.environment = 'development'
        end

        it "runs the feature block" do
          called = false
          paddock(:perimeter_fence) { called = true }
          called.should be_true
        end

        it "returns true from the feature check" do
          paddock(:perimeter_fence).should be_true
        end

        it "is indifferent to strings/symbols" do
          Paddock('development') do
            enable :perimeter_fence, :in => 'development'
          end

          called = false
          paddock(:perimeter_fence) { called = true }
          called.should be_true
        end
      end
    end

    context "when specifying multiple environments" do
      before(:each) do
        Paddock('development') do
          enable :perimeter_fence, :in => [:development, :test]
        end
      end

      context "when in appropriate environment" do
        before(:each) do
          Paddock.environment = 'development'
        end

        it "runs the feature block" do
          called = false
          paddock(:perimeter_fence) { called = true }
          called.should be_true
        end

        it "returns true from the feature check" do
          paddock(:perimeter_fence).should be_true
        end

        it "is indifferent to strings/symbols" do
          Paddock('development') do
            enable :perimeter_fence, :in => %w[development test]
          end

          called = false
          paddock(:perimeter_fence) { called = true }
          called.should be_true
        end
      end

      context "when not in appropriate environment" do
        before(:each) do
          Paddock.environment = 'production'
        end

        it "does not run the feature block when not in an appropriate environment" do
          called = false
          paddock(:perimeter_fence) { called = true }
          called.should be_false
        end

        it "returns false from the feature check" do
          paddock(:perimeter_fence).should be_false
        end
      end
    end
  end

  describe "disabling features" do
    before(:each) do
      Paddock('development') do
        disable :perimeter_fence
      end
    end

    it "does not run the feature block when not in an appropriate environment" do
      called = false
      paddock(:perimeter_fence) { called = true }
      called.should be_false
    end

    it "returns false from the feature check" do
      paddock(:perimeter_fence).should be_false
    end
  end

  describe "disabling features in certain environments" do
    before(:each) do
      Paddock('production') do
        disable :perimeter_fence, :in => :production
      end
    end

    it "does not run the feature block when not in an appropriate environment" do
      called = false
      paddock(:perimeter_fence) { called = true }
      called.should be_false
    end

    it "returns false from the feature check" do
      paddock(:perimeter_fence).should be_false
    end

    it "is indifferent to strings/symbols" do
      Paddock('development') do
        disable :perimeter_fence, :in => 'production'
      end

      called = false
      paddock(:perimeter_fence) { called = true }
      called.should be_true
    end
  end

  describe "using disabled features in different environment" do
    before(:each) do
      Paddock('development') do
        disable :perimeter_fence, :in => :production
      end
    end

    it "does not run the feature block when not in an appropriate environment" do
      called = false
      paddock(:perimeter_fence) { called = true }
      called.should be_true
    end

    it "returns false from the feature check" do
      paddock(:perimeter_fence).should be_true
    end

    it "is indifferent to strings/symbols" do
      Paddock('development') do
        disable :perimeter_fence, :in => %w[production other]
      end

      called = false
      paddock(:perimeter_fence) { called = true }
      called.should be_true
    end
  end

  describe "resetting changes" do
    before(:each) do
      Paddock('development') do
        disable :disabled_feature
        enable :enabled_feature
      end
    end

    it "restores original feature behavior" do
      Paddock.disable :enabled_feature
      paddock(:enabled_feature).should be_false

      Paddock.reset!
      paddock(:enabled_feature).should be_true
    end
  end
end
