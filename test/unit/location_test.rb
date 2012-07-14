require 'test_helper'

describe Location do

  it "includes name in to_param" do
    location = FactoryGirl.build_stubbed(:location, :name => "Republic of Vanuatu")
    location.to_param.must_equal "#{location.id}-republic-of-vanuatu"
  end

  it "should obey business hours" do
    # create a business hour exception - make sure this exception falls on one of
    # our regular business hour days
    date_closed = Time.zone.now
    while (!date_closed.monday? && !date_closed.wednesday?)
      date_closed = date_closed + 1.days
    end

    # get a day we know we should be open
    date_open = date_closed + 1.days
    while (!date_open.monday? && !date_open.wednesday?)
      date_open = date_open + 1.days
    end
    base_time = date_open.at_beginning_of_day

    location = FactoryGirl.build_stubbed(:location, :name => "Republic of Vanuatu") do |loc|
      # add business hours on two non-consecutive days, with a lunch break in the middle
      ["monday", "wednesday"].each do |open_day|
        # morning hours
        attrs = {
          :open_day   => open_day,
          :open_hour  => 9,
          :close_day  => open_day,
          :close_hour => 12
        }
        loc.business_hours.create(FactoryGirl.attributes_for(:business_hour, attrs))

        # afternoon hours
        attrs[:open_hour]  = 13
        attrs[:close_hour] = 17
        loc.business_hours.create(FactoryGirl.attributes_for(:business_hour, attrs))
      end

      loc.business_hour_exceptions.create(FactoryGirl.attributes_for(:business_hour_exception, :date_closed => date_closed))
    end

    location.business_hours.count.must_equal(4)
    location.business_hour_exceptions.count.must_equal(1)

    # test an hour which falls within the first set of business hours
    query_time = base_time + 12.hours
    # opens_at   = base_time + 9.hours
    # closes_at  = base_time + 17.hours
    # location.first_opening_time_on_date(query_time).must_equal(opens_at)
    # location.last_closing_time_on_date(query_time).must_equal(closes_at)

    location.open_on?(query_time).must_equal(true)
    location.closed_on?(query_time).must_equal(false)

    # test an hour which falls before the first set of business hours
    query_time = base_time
    # location.first_opening_time_on_date(query_time).must_equal(opens_at)
    # location.last_closing_time_on_date(query_time).must_equal(closes_at)
    location.open_on?(query_time).must_equal(true)
    location.closed_on?(query_time).must_equal(false)

    # test an hour which falls after the first set of business hours
    query_time = base_time + 23.hours + 59.minutes + 59.seconds
    # location.first_opening_time_on_date(query_time).must_equal(opens_at)
    # location.last_closing_time_on_date(query_time).must_equal(closes_at)
    location.open_on?(query_time).must_equal(true)
    location.closed_on?(query_time).must_equal(false)

    # test a day outside regular business hours
    query_time = base_time + 36.hours
    # location.first_opening_time_on_date(query_time).must_be_nil
    # location.last_closing_time_on_date(query_time).must_be_nil
    location.open_on?(query_time).must_equal(false)
    location.closed_on?(query_time).must_equal(true)

    # test a business hour exception
    query_time = date_closed + 12.hours
    # location.first_opening_time_on_date(query_time).must_be_nil
    # location.last_closing_time_on_date(query_time).must_be_nil
    location.open_on?(query_time).must_equal(false)
    location.closed_on?(query_time).must_equal(true)

    # make sure the exception is only the one day and the same day the
    # next week is open
    query_time = date_closed + 1.week
    # opens_at   = base_time + 2.days + 1.week + 9.hours
    # closes_at  = base_time + 2.days + 1.week + 17.hours
    # location.first_opening_time_on_date(query_time).must_equal(opens_at)
    # location.last_closing_time_on_date(query_time).must_equal(closes_at)
    location.open_on?(query_time).must_equal(true)
    location.closed_on?(query_time).must_equal(false)

  end

end
