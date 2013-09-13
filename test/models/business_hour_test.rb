require 'test_helper'

describe BusinessHour do

  it "should generate the correct number of occurences" do
    monday    = FactoryGirl.build_stubbed(:business_day)
    wednesday = FactoryGirl.build_stubbed(:business_day, index: 3, name: "Wednesday")
    friday    = FactoryGirl.build_stubbed(:business_day, index: 5, name: "Friday")
    bh        = FactoryGirl.build_stubbed(:business_hour, business_days: [monday, wednesday, friday])

    # starting next week
    d = (Time.zone.now + 7.days).at_beginning_of_week(:sunday)
    occurrences = bh.open_occurrences(10, d)
    occurrences.length.must_equal 5
    # TODO: figure out how to test something like this
    # occurrences.must_equal [[7, 18], [7, 20], [7, 23], [7, 25]]

  end


  it "should not be valid with missing or malformed fields" do
    params = {
      :open_hour    => 0,
      :open_minute  => 0,
      :close_hour   => 23,
      :close_minute => 0
    }

    # missing location
    monday   = FactoryGirl.build_stubbed(:business_day)
    bh       = FactoryGirl.build_stubbed(:business_hour, params.merge(business_days: [monday]))
    refute bh.valid?

    # missing business days
    location = FactoryGirl.build(:location)
    bh = FactoryGirl.build_stubbed(:business_hour, params.merge(location: location))
    refute bh.valid?

    # should have everything
    params[:business_days] = [monday]
    params[:location]      = location
    bh = FactoryGirl.build_stubbed(:business_hour, params)
    assert bh.valid?

    bh.close_hour = 24
    refute bh.valid?

    bh.open_hour = -1
    bh.close_hour = 23
    refute bh.valid?

    bh.open_hour = 0
    bh.open_minute = -1
    refute bh.valid?

    bh.open_minute = 60
    refute bh.valid?

    bh.open_minute = 0
    assert bh.valid?
  end

end
