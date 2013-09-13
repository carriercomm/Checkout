require 'test_helper'

describe Location do

  it "includes name in to_param" do
    location = FactoryGirl.build_stubbed(:location, :name => "Republic of Vanuatu")
    location.to_param.must_equal "#{location.id}-republic-of-vanuatu"
  end

  it "should obey business hours" do
    # create a business hour exception - make sure this exception falls on one of
    # our regular business hour days
    exception_date = Date.today
    while (!exception_date.monday? && !exception_date.wednesday?)
      exception_date += 1.days
    end

    # get a day we know we should be open
    date_open = exception_date + 1.days
    while (!date_open.monday? && !date_open.wednesday?)
      date_open += 1.days
    end

    monday    = FactoryGirl.build(:business_day)
    wednesday = FactoryGirl.build(:business_day, index: 3, name: "Wednesday")
    morning   = FactoryGirl.build(:business_hour, open_hour: 9, close_hour: 12, business_days: [monday, wednesday])
    afternoon = FactoryGirl.build(:business_hour, open_hour: 13, close_hour: 17, business_days: [monday, wednesday])
    exception = FactoryGirl.build(:business_hour_exception, :closed_at => exception_date)
    location  = FactoryGirl.create(:location, name: "Republic of Vanuatu", business_hours: [morning, afternoon], business_hour_exceptions: [exception])

    location.business_hours.length.must_equal(2)
    location.business_hour_exceptions.length.must_equal(1)

    base_time = date_open.at_beginning_of_day

    # test an hour which falls within the first set of business hours
    query_time = base_time + 12.hours
    assert location.open_on?(query_time), "location should be open on this date"

    # test an hour which falls before the first set of business hours
    query_time = base_time
    assert location.open_on?(query_time), "location should be open on this date"

    # test an hour which falls after the first set of business hours
    query_time = base_time + 23.hours + 59.minutes + 59.seconds
    assert location.open_on?(query_time), "location should be open on this date"

    # test a day outside regular business hours
    query_time = base_time + 36.hours
    refute location.open_on?(query_time), "location should not be open on this date"

    # test a business hour exception
    query_time = exception_date + 12.hours
    refute location.open_on?(query_time), "location should not be open on this exception date"

    # make sure the exception is only the one day and the same day the
    # next week is open
    query_time = exception_date + 1.week
    assert location.open_on?(query_time), "location should be open on this date"

  end

end
