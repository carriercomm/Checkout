require 'minitest_helper'

describe BusinessHour do

  it "should display correct open and close times" do
    monday = FactoryGirl.build_stubbed(:business_day)
    bh = FactoryGirl.build_stubbed(:business_hour, business_days: [monday])

    I18n.locale = :en
    bh.localized_open_time.must_equal "11:30am"
    bh.localized_close_time.must_equal "3:20pm"
    bh.to_s.must_equal "Mon 11:30am-3:20pm"

    I18n.locale = :fr
    bh.localized_open_time.must_equal "11:30"
    bh.localized_close_time.must_equal "15:20"
    bh.to_s.must_equal "Lun 11:30-15:20"

    wednesday = FactoryGirl.build_stubbed(:business_day, index: 3, name: "Wednesday")
    bh = FactoryGirl.build_stubbed(:business_hour, business_days: [monday, wednesday])
    bh.to_s.must_equal "Lun, Mer 11:30-15:20"

    I18n.locale = :en
    friday = FactoryGirl.build_stubbed(:business_day, index: 5, name: "Friday")
    bh = FactoryGirl.build_stubbed(:business_hour, business_days: [monday, wednesday, friday])
    bh.to_s.must_equal "Mon, Wed, Fri 11:30am-3:20pm"

    # == test occurrences ==
    # day in the past
    d = Time.parse("Sun, 15 Jul 2000 00:00:00 -0700")
    occurrences = bh.open_occurrences(10, d)
    occurrences.length.must_equal 0

    # starting next week
    d = (Time.zone.now + 7.days).at_beginning_of_week(:sunday)
    occurrences = bh.open_occurrences(10, d)
    occurrences.length.must_equal 4
    # TODO: figure out how to test something like this
    # occurrences.must_equal [[7, 18], [7, 20], [7, 23], [7, 25]]

    # test edge cases
    bh.open_hour  = 0
    bh.localized_open_time.must_equal "12:30am"
    bh.close_hour = 12
    bh.localized_close_time.must_equal "12:20pm"

    I18n.locale = :fr
    bh.open_hour  = 0
    bh.localized_open_time.must_equal "0:30"
    bh.close_hour = 12
    bh.localized_close_time.must_equal "12:20"

    I18n.locale = :en
  end

  it "should not be valid with missing or malformed fields" do
    params = {
      :open_hour    => 0,
      :open_minute  => 0,
      :close_hour   => 23,
      :close_minute => 0
    }

    # missing location
    monday = FactoryGirl.build_stubbed(:business_day)
    bh = FactoryGirl.build_stubbed(:business_hour, params.merge(:business_days => [monday]))
    bh.wont_be :valid?

    bh = FactoryGirl.build_stubbed(:business_hour_with_location, params)
    bh.wont_be :valid?

    # should have everything
    params[:business_days] = [monday]
    bh = FactoryGirl.build_stubbed(:business_hour_with_location, params)
    bh.must_be :valid?

    bh.close_hour = 24
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
    bh.must_be :valid?
  end

end
