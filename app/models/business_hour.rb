class BusinessHour < ActiveRecord::Base

  ## Macros ##

  resourcify


  ## Associations ##

  belongs_to :location, :inverse_of => :business_hours
  has_and_belongs_to_many :business_days


  ## Validations ##

  # TODO: validate with overlap detection for business hours

  validates_presence_of :location
  validates :open_hour,    :presence => true
  validates :open_hour,    :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 24 }
  validates :open_minute,  :presence => true
  validates :open_minute,  :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 60 }
  validates :close_hour,   :presence => true
  validates :close_hour,   :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 24 }
  validates :close_minute, :presence => true
  validates :close_minute, :numericality => { :only_integer => true,
                                              :greater_than_or_equal_to => 0,
                                              :less_than => 60 }
  validate :should_have_at_least_one_business_day
  validates :location_id,  :uniqueness => { :scope   => [:open_hour, :open_minute],
                                            :message => "You can't have duplicate open hours. Add additional days to the existing business hours instead." }


  ## Mass-assignable attributes ##

  attr_accessible(:location_id,
                  :business_day_ids,
                  :open_hour,
                  :open_minute,
                  :close_hour,
                  :close_minute)


  ## Class methods ##

  def self.hours_for_select
    (0..23).collect { |i| ["%02d" % i, i]}
  end

  def self.minutes_for_select
    [0, 15, 30, 45].collect { |i| ["%02d" % i, i] }
  end


  ## Instance methods ##

  def localized_hours(ref_time = Time.zone.now)
    "#{ localized_open_time(ref_time) }-#{ localized_close_time(ref_time) }"
  end

  def localized_abbr_business_days
    days = business_days.sort_by { |bd| bd.index }
    days.collect! { |bd| I18n.t('date.abbr_day_names')[bd.index].titleize }
    days.join(", ")
  end

  def localized_close_time(ref_time = Time.zone.now)
    time = ref_time.at_beginning_of_day + close_hour.hours + close_minute.minutes
    return I18n.l(time, :format => :business_hour).strip
  end

  def localized_open_time(ref_time = Time.zone.now)
    time = ref_time.at_beginning_of_day + open_hour.hours + open_minute.minutes
    return I18n.l(time, :format => :business_hour)
  end

  # returns an array of dates representing the days with
  # open business hours between now and days_out
  def open_occurrences(days_out = 90, date_start = Time.zone.now)
    schedule =  IceCube::Schedule.new(date_start)
    date_end = date_start + days_out.days

    # add a recurrence for each business day
    business_days.each do |bd|
      day = bd.name.downcase.to_sym
      schedule.add_recurrence_rule IceCube::Rule.weekly.day(day)
    end

    return schedule.occurrences(date_end)
  end

  def required_attrs_blank?
    return (open_hour.blank? || open_minute.blank? || close_hour.blank? || close_minute.blank?)
  end

  def should_have_at_least_one_business_day
    if business_days.empty?
      errors[:base] << "Should have at least one open day"
    end
  end

  def to_s(ref_time = Time.zone.now)
    "#{ localized_abbr_business_days } #{ localized_hours(ref_time) }"
  end

end
