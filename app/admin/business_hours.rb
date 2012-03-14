ActiveAdmin.register BusinessHour do

  filter :location

  form do |f|
    f.inputs "Details" do
      f.input :location
      f.input :day, :as => :select, :collection => BusinessHour.days_for_select
      f.input :open_at, :as => :time
      f.input :closed_at, :as => :time
    end
    f.buttons
  end

  index do
    column :location
    column "Hours" do |h|
      h.to_s
    end
    default_actions    
  end

  show do |bh|
    attributes_table do
      row :hours do
        bh.to_s
      end
    end
    active_admin_comments
  end


  controller do

    before_filter :munge_params, :only => [:create, :update]

    def new
      utc_offset = (Time.now.utc_offset / 60 / 60).to_s
      open  = DateTime.commercial(1969, 1, 1, 9, 0, 0, utc_offset)
      close = DateTime.commercial(1969, 1, 1, 17, 0, 0, utc_offset)
      @business_hour = BusinessHour.new(:open_at => open, :closed_at => close)
    end


    protected

    def munge_params
      

      # delete the junk in formtastic's weird ass format
      params['business_hour'].delete('open_at(1i)')
      params['business_hour'].delete('open_at(2i)')
      params['business_hour'].delete('open_at(3i)')
      params['business_hour'].delete('closed_at(1i)')
      params['business_hour'].delete('closed_at(2i)')
      params['business_hour'].delete('closed_at(3i)')

      # reconstruct the times in OUR weird ass format
      utc_offset = (Time.now.utc_offset / 60 / 60).to_s

      day           = params['business_hour'].delete('day')
      day           = Date::DAYS_INTO_WEEK[day.to_sym] + 1

      open_hour     = params['business_hour'].delete('open_at(4i)').to_i
      open_minute   = params['business_hour'].delete('open_at(5i)').to_i

      closed_hour   = params['business_hour'].delete('closed_at(4i)').to_i
      closed_minute = params['business_hour'].delete('closed_at(5i)').to_i

      logger.debug "---- open #{ day.inspect } #{ open_hour.inspect} #{ open_minute.inspect}"
      logger.debug "---- closed #{ day.inspect } #{ closed_hour.inspect} #{ closed_minute.inspect}"

      params['business_hour']['open_at']   = DateTime.commercial(1969, 1, day, open_hour, open_minute, 0, utc_offset)
      params['business_hour']['closed_at'] = DateTime.commercial(1969, 1, day, closed_hour, closed_minute, 0, utc_offset)
    end

  end

end
