require 'test_helper'

describe BusinessHour do

  it "should display correct open and close times" do
    params = {
      :open_day      => "monday",
      :open_hour     => 11,
      :open_minute   => 30,
      :close_day    => "monday",
      :close_hour   => 15,
      :close_minute => 20
    }

    bh = FactoryGirl.build_stubbed(:business_hour, params)

    bh.open_time_s.must_equal "11:30am"
    bh.close_time_s.must_equal "3:20pm"
    
    bh.to_s.must_equal "Monday 11:30am-3:20pm"

    # test edge cases
    bh.open_hour  = 0
    bh.open_time_s.must_equal "12:30am"

    bh.close_hour = 12
    bh.close_time_s.must_equal "12:20pm"
  end

  it "should be valid with in-order hours" do
    params = {
      :open_day     => "monday",
      :open_hour    => 11,
      :open_minute  => 0,
      :close_day    => "monday",
      :close_hour   => 15,
      :close_minute => 0
    }

    bh = FactoryGirl.build_stubbed(:business_hour, params)
    bh.must_be :valid?
  end

  it "should not be valid with out-of-order hours" do
    params = {
      :open_day     => "monday",
      :open_hour    => 15,
      :open_minute  => 0,
      :close_day    => "monday",
      :close_hour   => 11,
      :close_minute => 0
    }

    bh = FactoryGirl.build_stubbed(:business_hour, params)
    bh.wont_be :valid?

    bh.open_day = "tuesday"
    bh.open_hour = 2
    bh.wont_be :valid?
  end

  it "should not be valid with missing or malformed fields" do
    params = {
      :open_day     => "monday",
      :open_hour    => 0,
      :open_minute  => 0,
      :close_day    => "monday",
      :close_hour   => 24,
      :close_minute => 0
    }

    bh = FactoryGirl.build_stubbed(:business_hour, params)
    bh.wont_be :valid?

    bh.open_hour = -1
    bh.close_hour = 23
    bh.wont_be :valid?

    bh.open_hour = 0
    bh.open_minute = -1
    bh.wont_be :valid?

    bh.open_minute = 60
    bh.wont_be :valid?

    bh.open_minute = 0
    bh.open_day = "pound cake"
    bh.wont_be :valid?
  end

end
