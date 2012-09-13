namespace :dbx do

  desc 'reload the dbx db from a sql backup'
  task :reload => :environment do
    files = Dir.glob("#{Rails.root}/db/dbx*.sql")
    files.sort!
    `mysql --user=root -p dbx2 < #{files.last}`
  end

  desc 'migrate data from dbx'
  task :migrate => :environment do
    require 'tasks/legacy_classes'

    #
    # Clean up the database a bit
    #

    LegacyEquipment.dedupe_brands!
    LegacyEquipment.dedupe_serial_numbers!
    LegacyEquipment.convert_special_to_boolean!
    LegacyEquipment.convert_checkoutable_to_boolean!
    LegacyEquipment.convert_insured_to_boolean!
    LegacyEquipment.convert_eq_removed_to_boolean!
    LegacyEquipment.fill_in_blank_model_names!

    #
    # Migrate Brands
    #

    puts "Migrating brands..."

    success_count = 0
    error_count   = 0

    LegacyEquipment.all.each do |le|
      next if le.eq_manufacturer.nil?
      le.eq_manufacturer.strip!
      next if le.eq_manufacturer.nil? || le.eq_manufacturer.empty?
      begin
        brand = Brand.where("UPPER(name) = ?", le.eq_manufacturer.upcase).first
        brand = Brand.new(name: le.eq_manufacturer) if brand.nil?
        if brand.new_record?
          if brand.save
            success_count += 1
          else
            error_count += 1
            puts "\tError saving #{brand.id}:'#{ brand.name }'"
          end
        end
      rescue StandardError => e
        error_count += 1
        puts "\tError migrating #{le.id}: #{ e }"
      end
    end

    puts "Successfully migrated #{ success_count } brands"
    puts "#{ error_count } errors"
    puts

    #
    # Migrate Categories
    #

    puts "Migrating categories..."

    success_count = 0
    error_count   = 0

    LegacyCategory.all.each do |lc|
      category_name = (lc.category.nil?) ? "Unknown" : lc.category.strip

      begin
        cat = Category.find_or_initialize_by_name(category_name)
        if cat.new_record?
          cat.description = lc.cat_notes
          if cat.save
            success_count += 1
          else
            error_count += 1
            puts "\tError saving #{cat.id}:'#{ cat.name }'"
          end
        end
      rescue StandardError => e
        error_count += 1
        puts "\tError migrating #{lc.category}: #{ e }"
      end
    end

    puts "Successfully migrated #{ success_count } brands"
    puts "#{ error_count } errors"
    puts

    #
    # Migrate Models
    #

    puts "Migrating models..."

    success_count = 0
    error_count   = 0
    unknown_count = 0

    LegacyEquipment.includes(:legacy_category)
      .group(['eq_manufacturer', 'eq_model'])
      .order(['eq_manufacturer', 'eq_model'])
      .each do |le|

      # puts le.eq_manufacturer.ljust(30) + " | " + le.eq_model.ljust(30) + " | " + (le.category.blank? ? "" : le.category)

      begin
        # look up the brand
        brand = Brand.where("UPPER(name) = ?", le.eq_manufacturer.upcase).first
        brand = Brand.new(name: le.eq_manufacturer) if brand.nil?

        # normalize the model name
        model_name = (le.eq_model.blank?) ? (unknown_count += 1; "Unknown (#{ unknown_count })") : le.eq_model.strip

        # look up the model
        model_obj = brand.component_models.where("UPPER(TRIM(component_models.name)) = ?", model_name.upcase).first
        model_obj = brand.component_models.build(name: model_name)

        if model_obj.new_record?
          # set the description
          model_obj.description = le.eq_description

          # parse the training requirement
          model_obj.training_required = le.special

          category_name = (le.legacy_category.nil? || le.legacy_category.category.nil?) ? "Unknown" : le.legacy_category.category.strip
          model_obj.categories = [Category.where(:name => category_name).first_or_create]

          if model_obj.save
            success_count += 1
          else
            error_count += 1
            puts "\tError saving #{model_obj.id}:'#{ model_obj.name }'"
            puts model_obj.errors.inspect
          end
        end
      rescue StandardError => e
        error_count += 1
        puts "\tError migrating #{le.eq_model}: #{ e }"
      end
    end

    puts "Successfully migrated #{ success_count } models"
    puts "#{ error_count } errors"
    puts

    #
    # Migrate Budgets
    #

    puts "Migrating budgets..."
    success_count = 0
    error_count   = 0

    LegacyEquipment.select(['budget_number', 'budget_name', 'eq_budget_biennium'])
      .uniq
      .joins("INNER JOIN budgets ON equipment.budget_id = budgets.budget_id")
      .order(['eq_budget_biennium', 'budget_number'])
      .each do |le|

      begin
        le.budget_number.strip!       unless le.budget_number.nil?
        le.budget_name.strip!         unless le.budget_name.nil?
        le.eq_budget_biennium.strip!  unless le.eq_budget_biennium.nil?

        number = le.budget_number
        nom    = (!le.budget_name.blank? && le.budget_name.downcase != "unknown") ? le.budget_name : nil
        bienn  = (!le.eq_budget_biennium.blank? && le.eq_budget_biennium.downcase != "unknown") ? le.eq_budget_biennium : nil
        date_start, date_end = nil

        # try to parse biennium
        unless bienn.nil?
          ds, de = bienn.split("-")
          unless de.nil?
            date_start = Date.new(ds.to_i, 7, 1).to_s
            date_end   = Date.new(de.to_i, 6, 30).to_s
          end
        end

        budget = Budget.where(:number => number, :name => nom, :date_start => date_start, :date_end => date_end).first_or_initialize

        if budget.new_record?
          if budget.save
            success_count += 1
          else
            error_count += 1
            puts "\tError saving #{budget.id}:  #{ budget.to_s } #{ budget.errors.inspect.to_s }"
          end
        end
      rescue StandardError => e
        error_count += 1
        puts le.budget_number.ljust(30) + " | " + le.budget_name.ljust(30) + " | " + le.eq_budget_biennium
        puts "\tError migrating #{le.budget_number}: #{ e }"
      end
    end

    puts "Successfully migrated #{ success_count } budgets"
    puts "#{ error_count } errors"
    puts

    #
    # Migrate Components
    #

    puts "Migrating asset tags, kits, and components..."
    success_count = 0
    error_count = 0

    LegacyEquipment.includes(:legacy_budget, :legacy_location).all.each do |le|

      begin
        # look up the brand
        brand = Brand.where("UPPER(name) = ?", le.eq_manufacturer.upcase).first

        # look up the model
        model_name = le.eq_model.blank? ? "Unknown" : le.eq_model.strip
        model_obj = brand.component_models.where("UPPER(component_models.name) = ?", model_name.upcase).first

        # look up the budget
        le.legacy_budget.budget_number.strip! unless le.legacy_budget.budget_number.nil?
        le.legacy_budget.budget_name.strip!   unless le.legacy_budget.budget_name.nil?
        le.eq_budget_biennium.strip!          unless le.eq_budget_biennium.nil?

        number = le.legacy_budget.budget_number
        nom    = (!le.legacy_budget.budget_name.blank? && le.legacy_budget.budget_name.downcase != "unknown") ? le.legacy_budget.budget_name : nil
        bienn  = (!le.eq_budget_biennium.blank? && le.eq_budget_biennium.downcase != "unknown") ? le.eq_budget_biennium : nil
        date_start, date_end = nil

        # try to parse biennium
        unless bienn.nil?
          ds, de = bienn.split("-")
          unless de.nil?
            date_start = Date.new(ds.to_i, 7, 1).to_s
            date_end   = Date.new(de.to_i, 6, 30).to_s
          end
        end

        budget = Budget.where(:number => number, :name => nom, :date_start => date_start, :date_end => date_end).first

        # find or create a matching asset tag
        component = Component.where(:asset_tag => le.eq_uw_tag.to_s).first_or_initialize

        if component.new_record?
          # start building up the component's attrs
          serial_number      = le.eq_serial_num.try(:strip)
          cost               = (le.eq_cost == 0) ? nil : le.eq_cost
          insured            = le.eq_insured
          missing            = le.eq_removed
          checkoutable       = le.checkoutable

          component.component_model = model_obj
          component.missing         = missing
          component.serial_number   = serial_number
          component.created_at      = le.eq_date_entered

          kit                = Kit.new
          kit.budget         = budget
          kit.checkoutable   = checkoutable
          kit.cost           = cost
          kit.insured        = insured
          kit.location       = Location.find_or_create_by_name(le.legacy_location.loc_name)
          kit.tombstoned     = missing

          kit.components << component

          if kit.save
            success_count += 1
          else
            error_count += 1
            puts "Error saving #{ le.eq_uw_tag }:"
            puts model_name.inspect
            puts model_obj.inspect
            puts
            puts component.errors.inspect
            puts
            puts kit.errors.inspect
            puts "----"
          end

        end
      rescue StandardError => e
        error_count += 1
        puts "\tError migrating #{le.eq_uw_tag}: #{ e }"
        puts e.backtrace
      end
    end

    puts "Successfully migrated #{ success_count } asset tags, kits, and components"
    puts "#{ error_count } errors"
    puts

    #
    # Create Covenants
    #

    puts "Creating covenants..."
    sor = Covenant.create!(name:"Statement of Responsibility", description:'Users have signed and submitted the "Statement of Responsibility"')


    #
    # Migrate Users
    #

    puts "Migrating users..."
    success_count = 0
    error_count   = 0

    LegacyUser.all.each do |lu|
     begin
       username = lu.client_id.strip
       name = lu.name.split(',')
       first_name = String.new
       last_name  = String.new
       if name.size > 1
         last_name = name.first.strip
         first_name = name.last.strip
       else
         name = lu.name.split(" ")
         last_name = name.pop.strip
         first_name = name.join(" ").strip
       end
       email = username + "@uw.edu"
       password = Devise.friendly_token.first(6)
       u = User.new
       u.username = username
       u.first_name = first_name
       u.last_name = last_name
       u.email = email
       u.password = password
       if lu.stat_of_responsibility.downcase.strip == "yes"
         u.covenants = [sor]
       end
       u.save!
       success_count += 1
     rescue StandardError => e
       error_count += 1
       puts "\tError migrating #{lu.client_id}: #{ e }"
       #puts e.backtrace
     end
    end

    puts "Successfully migrated #{ success_count } users"
    puts "#{ error_count } errors"
    puts


    #
    # Migrate Groups/Permissions
    #

    puts "Migrating groups and permissions..."
    group_success_count = 0
    permissions_success_count = 0
    error_count = 0

    LegacyGroup.includes(:legacy_permissions).all.each do |lg|
      begin
        g = Group.create!(name: lg.group_name, description: lg.group_description)
        group_success_count += 1
        lg.legacy_permissions.each do |lp|
          c = Component.find_by_asset_tag(lp.eq_uw_tag.to_s)
          raise "No asset tag: #{ lp.eq_uw_tag }" if c.nil?
          g.kits << c.kit
          permissions_success_count += 1
        end
        g.save
      rescue StandardError => e
        error_count += 1
        puts "\tError migrating #{lg.group_id}: #{ e }"
        puts e.backtrace
      end
    end

    puts "Successfully migrated #{ group_success_count } groups with #{ permissions_success_count } permissions"
    puts "#{ error_count } errors"
    puts

  end
end

namespace :db do
  desc "drop, create, migrate"
  task :rebuild => ["db:drop", "db:create", "db:migrate", "db:seed"]

  desc "drop, create, migrate, dbx:migrate"
  task :repop => ["db:rebuild", "dbx:migrate", "db:seed_dev"]

  desc "loads some fake data, helpful for development"
  task :seed_dev => :environment do

    bd = BusinessDay.order("business_days.index").all.collect { |bd| bd.id }

    Location.all.each_with_index do |l,idx|
      if idx % 2  == 0
        # morning hours
        attrs = {
          :business_day_ids => [bd[1], bd[3], bd[5]],
          :open_hour   => 9,
          :open_minute => 30,
          :close_hour  => 12,
          :close_minute => 15
        }
        l.business_hours.create(attrs)

        # afternoon hours
        attrs[:open_hour]    = 13
        attrs[:open_minute]  = 00
        attrs[:close_hour]   = 17
        attrs[:close_minute] = 00
        l.business_hours.create(attrs)

      else
        attrs = {
          :business_day_ids => [bd[2], bd[4]],
          :open_hour   => 10,
          :open_minute => 00,
          :close_hour  => 2,
          :close_minute => 0
        }
        l.business_hours.create(attrs)
      end
      l.save
    end

    BusinessHour.all.each do |x|
      open_days = x.open_occurrences
      open_days.each_with_index do |y, idx|
        if idx % 5 == 0
          BusinessHourException.create!(:location => x.location, :date_closed => Date.new(Time.now.year, y.first, y.last))
        end
      end
    end

  end

end
