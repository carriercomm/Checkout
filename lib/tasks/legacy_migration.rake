namespace :dbx do

  desc 'reload the dbx db from a sql backup'
  task :reload => :environment do
    files = Dir.glob("#{Rails.root}/db/dbx*.sql.gz")
    files.sort!
    puts files.last
    `gzcat #{files.last} | mysql --user=root -p dbx2`
  end

  desc 'migrate data from dbx'
  task :migrate  => :environment do
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

    LegacyEquipment.find_in_batches do |batch|
      batch.each do |le|
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

    puts "Successfully migrated #{ success_count } categories"
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
        starts_at, ends_at = nil

        # try to parse biennium
        unless bienn.nil?
          ds, de = bienn.split("-")
          unless de.nil?
            starts_at = Date.new(ds.to_i, 7, 1).to_s
            ends_at   = Date.new(de.to_i, 6, 30).to_s
          end
        end

        budget = Budget.where(:number => number, :name => nom, :starts_at => starts_at, :ends_at => ends_at).first_or_initialize

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
    # Migrate Locations
    #

    puts "Migrating locations and business hours..."

    bd = BusinessDay.order("business_days.index").all.collect { |bd| bd.id }

    LegacyLocation.all.each do |l|
      location = Location.find_or_create_by_name(l.loc_name)
      if location.name == "Raitt"
        # M, W
        attrs = {
          :business_day_ids => [bd[1], bd[3]],
          :open_hour   => 10,
          :open_minute => 30,
          :close_hour  => 13,
          :close_minute => 20
        }
        location.business_hours.create(attrs)

        # F
        attrs[:business_day_ids] = [bd[5]]
        attrs[:open_hour]    = 11
        attrs[:open_minute]  = 30
        attrs[:close_hour]   = 13
        attrs[:close_minute] = 20
        location.business_hours.create(attrs)

      else
        attrs = {
          :business_day_ids => [bd[2], bd[4]],
          :open_hour   => 10,
          :open_minute => 00,
          :close_hour  => 2,
          :close_minute => 0
        }
        location.business_hours.create(attrs)
      end
    end

    puts "Successfully migrated #{ Location.count } locations"
    puts


    #
    # Migrate Equipment
    #

    puts "Migrating kits, and components..."
    success_count = 0
    error_count = 0

    LegacyEquipment.includes(:legacy_budget, :legacy_location).find_in_batches do |batch|
      batch.each do |le|
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
          starts_at, ends_at = nil

          # try to parse biennium
          unless bienn.nil?
            ds, de = bienn.split("-")
            unless de.nil?
              starts_at = Date.new(ds.to_i, 7, 1).to_s
              ends_at   = Date.new(de.to_i, 6, 30).to_s
            end
          end

          budget = Budget.where(:number => number, :name => nom, :starts_at => starts_at, :ends_at => ends_at).first

          # find or create a matching asset tag
          component = Component.where(:asset_tag => le.eq_uw_tag.to_s).first_or_initialize

          if component.new_record?
            # start building up the component's attrs
            serial_number      = le.eq_serial_num.try(:strip)
            cost               = (le.eq_cost == 0) ? nil : le.eq_cost
            insured            = le.eq_insured
            checkoutable       = le.checkoutable

            component.component_model = model_obj
            component.serial_number   = serial_number
            component.created_at      = le.eq_date_entered

            # create an accession record
            accession_record = InventoryRecord.new
            accession_record.inventory_status = InventoryStatus.find_by_name("accessioned")
            accession_record.created_at = component.created_at
            accession_record.attendant = User.system_user
            component.inventory_records << accession_record

            if le.eq_removed
              # create a deaccession record
              inventory_record = InventoryRecord.new
              inventory_record.inventory_status = InventoryStatus.find_by_name("deaccessioned")
              inventory_record.attendant = User.system_user
              component.inventory_records << inventory_record
            end

            kit                = Kit.new
            kit.budget         = budget
            kit.checkoutable   = checkoutable
            kit.cost           = cost
            kit.insured        = insured
            kit.location       = Location.find_or_create_by_name(le.legacy_location.loc_name)
            kit.tombstoned     = le.eq_removed

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
    end

    puts "Successfully migrated #{ success_count } asset tags, kits, and components"
    puts "#{ error_count } errors"
    puts


    #
    # Create Covenants
    #

    puts "Creating covenants..."
    puts
    sor = Covenant.create!(name:"Statement of Responsibility", description:'Users have signed and submitted the "Statement of Responsibility"')

    #
    # Migrate Users
    #

    puts "Migrating users..."
    success_count = 0
    error_count   = 0

    current_user = ["jehughes", "bgrace", "mtm5", "coupe", "maja08", "karpen", "pampin", "hana21", "steliosm", "varchaus", "rtwomey", "annabelc", "mtrainor", "tivon", "peberger", "ozubko", "shawnx", "mones", "joshp", "ganter", "blake", "mwatras", "hraikes", "hugosg", "trebacze", "mem5", "jimified", "marcinp", "chesnd", "swlcomp"]

    admins = ["jehughes", "bgrace", "mtm5", "coupe", "karpen", "pampin", "trebacze", "shawnx"]

    attendants = ["maja08", "hana21", "steliosm", "varchaus", "rtwomey", "annabelc", "mtrainor", "tivon", "joshp", "hraikes", "hugosg", "mem5", "jimified", "marcinp", "chesnd", "swlcomp"]

    LegacyUser.all.each do |lu|
      begin
        username = lu.client_id.gsub(/[^a-z0-9]/, "").strip
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
        u.disabled = (current_user.include? username) ? false : true
        u.save!
        if admins.include?(username)
          u.add_role "admin"
        end
        if attendants.include?(username)
          u.add_role "attendant"
        end
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
    users_success_count = 0
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

        lg.legacy_users.map(&:client_id).each do |username|
          u = User.find_by_username(username)
          # don't bother unless this is an active user
          unless u.nil? #|| u.disabled
            g.users << u
            users_success_count += 1
          end
        end

        g.save
      rescue StandardError => e
        error_count += 1
        puts "\tError migrating #{lg.group_id}: #{ e }"
        puts e.backtrace
      end
    end

    puts "Successfully migrated #{ group_success_count } groups"
    puts "\t#{ permissions_success_count } permissions"
    puts "\t#{ users_success_count } memberships"
    puts "#{ error_count } errors"
    puts

  end


  desc 'migrate data from dbx'
  task :training  => :environment do
    require 'tasks/legacy_classes'

    Training.delete_all

    puts "Migrating training info..."
    success_count = 0
    error_count = 0

    LegacyTraining.all.each do |lt|
      c = Component.find_by_asset_tag(lt.eq_uw_tag.to_s)
      u = User.find_by_username(lt.client_id.downcase.squish)
      if c && u
        begin
          Training.create!(user: u, component_model: c.component_model)
        rescue StandardError => e
          error_count += 1
          puts "\tError migrating #{lt.special_id}: #{ e }"
#          puts e.backtrace
        end
        success_count += 1
      else
        puts "\tError migrating #{lt.special_id}: couldn't find component or user"
        error_count += 1
      end
    end

    puts "Successfully migrated #{ success_count } trainings"
    puts "#{ error_count } errors"
    puts

  end

  desc 'migrate data from dbx'
  task :res  => :environment do
    require 'tasks/legacy_classes'

    Loan.delete_all

    #
    # Migrate Checkouts/Reservations
    #

    puts "Migrating checkouts and reservations..."
    checkout_success_count = 0
    reservation_success_count = 0
    error_count = 0

    #
    # Clean up the database a bit
    #

    LegacyCheckout.nullify_bogus_values!
    LegacyCheckout.create_indexes!
    LegacyReservation.nullify_bogus_values!
    LegacyReservation.create_indexes!

    system_approver = User.unscoped.find_by_username("system")

    LegacyReservation.includes(:legacy_checkout).find_in_batches do |batch|
      batch.each do |r|
        begin
          client_id = r.client_id.downcase.gsub(/[^a-z0-9]/, "").strip
          client = User.find_by_username(client_id)
          raise "couldn't find reservation client: #{ client_id }" if client.nil?

          kit = Kit.find_by_asset_tag(r.eq_uw_tag)
          raise "couldn't find kit: #{ r.eq_uw_tag }" if kit.nil?

          l = Loan.new
          l.importing = true
          l.starts_at = r.resdate
          if r.resdate_end.nil?
            l.ends_at = kit.default_return_date(l.starts_at)
            if l.ends_at.nil?
              puts "screwed up"
              d = AppConfig.instance.default_checkout_length
              puts d.to_s
              puts l.starts_at.inspect
              expected_time = (l.starts_at + d.days).to_time
              puts expected_time
              puts kit.location.inspect
              puts kit.location.next_date_open(expected_time).inspect
              exit
            end
          else
            l.ends_at = r.resdate_end
          end
          l.client    = client
          l.kit       = kit

          c = r.legacy_checkout
          unless c.nil?
            staffout_id     = c.staffout_id.downcase.gsub(/[^a-z0-9]/, "").strip
            staffin_id      = c.staffin_id.downcase.gsub(/[^a-z0-9]/, "").strip
            out_assistant   = User.find_by_username(staffout_id)
            in_assistant    = User.find_by_username(staffin_id)

            l.out_at        = c.dateout     unless c.dateout.nil?
            l.ends_at       = c.datedue || kit.default_return_date(l.starts_at) if l.ends_at.nil?
            l.in_at         = c.datein      unless c.datein.nil?
            l.out_assistant = out_assistant unless out_assistant.nil?
            l.in_assistant  = in_assistant  unless in_assistant.nil?
          end

          if l.in_assistant
            l.state = "checked_in"
          elsif l.out_assistant
            l.state = "checked_out"
          elsif l.starts_at
            if l.starts_at >= Date.today
              l.state = "approved"
              l.approver = system_approver
            else
              l.state = "canceled"
            end
          end

          if l.save
            reservation_success_count += 1
            if r.legacy_checkout
              checkout_success_count += 1
            end
            unless l.valid?
              puts "--------"
              puts "\tError migrating #{r.res_id}:"
              puts "\t\t #{ l.inspect }"
              puts "\t\t #{ r.inspect }"
              puts "\t\t #{ c.inspect }"
              l.errors.messages.each {|k,v| puts "\t\t#{ k.to_s.titleize } #{ v }" }
            end
          else
            puts "--------"
            puts "\tError migrating #{r.res_id}:"
            puts "\t\t #{ l.inspect }"
            puts "\t\t #{ r.inspect }"
            puts "\t\t #{ c.inspect }"
            l.errors.messages.each {|k,v| puts "\t\t#{ k.to_s.titleize } #{ v }" }
            error_count += 1
          end
        rescue StandardError => e
          error_count += 1
          puts "\tError migrating #{r.res_id}: #{ e }"
          puts e.backtrace
        end
      end
    end

    # migrate the checkouts that didn't have a reservation
    # some of these have a reservation id, but no corresponding reservation record
    where_clause = "res_id IS NULL OR (checkout.res_id IS NOT NULL AND checkout.res_id NOT IN (select res_id from reservation))"
    LegacyCheckout.where(where_clause).find_in_batches do |batch|
      batch.each do |c|
        begin
          client_id = c.client_id.downcase.gsub(/[^a-z0-9]/, "").strip
          client = User.find_by_username(client_id)
          raise "couldn't find checkout client: #{ client_id }" if client.nil?

          kit = Kit.find_by_asset_tag(c.eq_uw_tag)
          raise "couldn't find kit: #{ c.eq_uw_tag }" if kit.nil?

          out_assistant = User.find_by_username(c.staffout_id)
          in_assistant  = User.find_by_username(c.staffin_id)

          l = Loan.new
          l.importing     = true
          l.client        = client
          l.kit           = kit
          l.starts_at     = c.dateout
          l.ends_at       = c.datedue || kit.default_return_date(l.starts_at)
          l.out_at        = c.dateout     unless c.dateout.nil?
          l.in_at         = c.datein      unless c.datein.nil?
          l.out_assistant = out_assistant unless out_assistant.nil?
          l.in_assistant  = in_assistant  unless in_assistant.nil?

          if l.in_assistant
            l.state = "checked_in"
          elsif l.out_assistant
            l.state = "checked_out"
          else
            raise "Couldn't determine what state this checkout should be in: #{ c.checkout_id }"
          end

          if l.save
            checkout_success_count += 1
            unless l.valid?
              puts "--------"
              puts "\tError migrating #{c.checkout_id}:"
              puts "\t\t #{ l.inspect }"
              puts "\t\t #{ c.inspect }"
              l.errors.messages.each {|k,v| puts "\t\t#{ k.to_s.titleize } #{ v }" }
            end
          else
            puts "--------"
            puts "\tError migrating #{c.checkout_id}:"
            puts "\t\t #{ l.inspect }"
            puts "\t\t #{ c.inspect }"
            l.errors.messages.each {|k,v| puts "\t\t#{ k.to_s.titleize } #{ v }" }
            error_count += 1
          end
        rescue StandardError => e
          error_count += 1
          puts "\tError migrating #{c.checkout_id}: #{ e }"
        end
      end
    end

    puts "Successfully migrated #{ reservation_success_count } of #{ LegacyReservation.count.to_s } reservations"
    puts "\t#{ checkout_success_count } of #{ LegacyCheckout.count.to_s } checkouts"
    puts "#{ error_count } errors"
    puts

  end

  desc 'migrate inventory data from dbx'
  task :inventory  => :environment do
    require 'tasks/legacy_classes'

    puts "Migrating inventory records..."
    success_count = 0
    error_count   = 0

    inventoried = InventoryStatus.find_by_name("inventoried")

    InventoryRecord.where("inventory_status_id = ?", inventoried.id).delete_all

    LegacyInventory.all.each do |li|
      ir = InventoryRecord.new
      ir.component = Component.find_by_asset_tag(li.eq_uw_tag.to_s)
      ir.inventory_status = inventoried
      ir.created_at = li.date_inventoried
      ir.attendant = User.find_by_username(li.staff_id)

      if ir.save
        success_count += 1
      else
        puts "--------"
        puts "\tError migrating #{li.inventory_id}:"
        puts "\t\t #{ li.inspect }"
        puts "\t\t #{ ir.inspect }"
        ir.errors.messages.each {|k,v| puts "\t\t#{ k.to_s.titleize } #{ v }" }
        error_count += 1
      end
    end

    puts "Successfully migrated #{ success_count } of #{ LegacyInventory.count.to_s } inventory records"
    puts "#{ error_count } errors"
    puts

  end

end


namespace :db do
  desc "drop, create, schema load"
  task :rebuild => ["db:drop", "db:create", "db:schema:load", "db:migrate", "db:seed"]

  desc "drop, create, schema load, dbx:migrate"
  task :repop => ["db:rebuild", "dbx:migrate", "dbx:training", "dbx:res", "dbx:inventory", "db:seed_dev"]

  desc "loads some fake data, helpful for development"
  task :seed_dev => :environment do

    # add some random business hour exceptions
    BusinessHour.all.each do |x|
      open_days = x.open_occurrences
      open_days.each_with_index do |y, idx|
        if idx % 5 == 0
          BusinessHourException.first_or_create(:location => x.location, :closed_at => Date.new(Time.now.year, y.month, y.day))
        end
      end
    end

  end

end
