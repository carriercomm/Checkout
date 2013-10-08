require 'progress_bar'

namespace :dbx do

  desc 'dump a current snapshot of the database on ovid'
  task :dump => :environment do
    `ssh dxarts@ovid01.u.washington.edu '/rc00/d32/dxarts/bin/mysqldump_dbx'`
  end

  desc 'dump and fetch a current snapshot of the database from ovid'
  task :dump_and_fetch => [:environment, "dbx:dump", "dbx:fetch"]

  desc 'fetch a current snapshot of the database from ovid'
  task :fetch => :environment do
    file = `ssh dxarts@ovid01.u.washington.edu '~/bin/latest_dbx_backup_file_name'`
    Dir.chdir("#{Rails.root}/db") do
      `scp dxarts@ovid01.u.washington.edu:#{file.chomp} .`
    end
  end

  desc 'reload the dbx db from a sql backup'
  task :reload => :environment do
    files = Dir.glob("#{Rails.root}/db/dbx*.sql.gz")
    files.sort!
    puts files.last
    `gzcat #{files.last} | mysql --user=root -p dbx2`
  end

  task :init => :environment do
    require 'tasks/legacy_classes'

    log_file = File.join(Rails.root, "log", "importer.log")
    puts "Logging to: #{ log_file }"
    @logger = Logger.new(log_file)
  end

  desc 'migrate data from dbx'
  task :migrate  => :init do

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
    @logger.info "==== BRANDS ===="

    success_count = 0
    error_count   = 0

    pb = ProgressBar.new(LegacyEquipment.count)

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
              @logger.error "Error saving #{brand.id}:'#{ brand.name }'"
            end
          end
        rescue StandardError => e
          error_count += 1
          @logger.error "Error migrating #{le.id}: #{ e }"
        end
        pb.increment!
      end
    end

    @logger.info "Successfully migrated #{ success_count } brands"
    @logger.info "#{ error_count } errors"

    #
    # Migrate Categories
    #

    puts "Migrating categories..."
    @logger.info "==== CATEGORIES ===="

    success_count = 0
    error_count   = 0

    pb = ProgressBar.new(LegacyCategory.count)

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
            @logger.error "Error saving #{cat.id}:'#{ cat.name }'"
          end
        end
      rescue StandardError => e
        error_count += 1
        @logger.error "Error migrating #{lc.category}: #{ e }"
      end
      pb.increment!
    end

    @logger.info "Successfully migrated #{ success_count } categories"
    @logger.info "#{ error_count } errors"

    #
    # Migrate Models
    #

    puts "Migrating models..."
    @logger.info "==== MODELS ===="

    success_count = 0
    error_count   = 0
    unknown_count = 0


    models_count = LegacyEquipment.includes(:legacy_category).group(['eq_manufacturer', 'eq_model']).all.size
    pb = ProgressBar.new(models_count)

    LegacyEquipment.includes(:legacy_category)
      .group(['eq_manufacturer', 'eq_model'])
      .order(['eq_manufacturer', 'eq_model']).each do |le|

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
            @logger.error "Error saving #{model_obj.id}:'#{ model_obj.name }'"
            @logger.error model_obj.errors.inspect
          end
        end
      rescue StandardError => e
        error_count += 1
        @logger.error "Error migrating #{le.eq_model}: #{ e }"
      end
      pb.increment!
    end

    @logger.info "Successfully migrated #{ success_count } models"
    @logger.info "#{ error_count } errors"


    #
    # Migrate Budgets
    #

    puts "Migrating budgets..."
    @logger.info "==== BUDGETS ===="

    success_count = 0
    error_count   = 0

    budgets_count = LegacyEquipment.select(['budget_number', 'budget_name', 'eq_budget_biennium'])
      .uniq
      .joins("INNER JOIN budgets ON equipment.budget_id = budgets.budget_id")
      .order(['eq_budget_biennium', 'budget_number']).all.size

    pb = ProgressBar.new(budgets_count)

    LegacyEquipment.select(['budget_number', 'budget_name', 'eq_budget_biennium'])
      .uniq
      .joins("INNER JOIN budgets ON equipment.budget_id = budgets.budget_id")
      .order(['eq_budget_biennium', 'budget_number']).each do |le|

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
            @logger.error "Error saving #{budget.id}:  #{ budget.to_s } #{ budget.errors.inspect.to_s }"
          end
        end
      rescue StandardError => e
        error_count += 1
        @logger.error le.budget_number.ljust(30) + " | " + le.budget_name.ljust(30) + " | " + le.eq_budget_biennium
        @logger.error "Error migrating #{le.budget_number}: #{ e }"
      end
      pb.increment!
    end

    @logger.info "Successfully migrated #{ success_count } budgets"
    @logger.info "#{ error_count } errors"


    #
    # Migrate Locations
    #

    puts "Migrating locations and business hours..."
    @logger.info "==== LOCATIONS AND BUSINESS HOURS ===="

    bd = BusinessDay.order("business_days.index").all.collect { |bd| bd.id }

    LegacyLocation.all.each do |l|
      next if l.loc_name.nil?
      location = Location.where(name: l.loc_name).first_or_initialize
      if location.name == "Raitt" && location.new_record?
        # M
        attrs = {
          :business_day_ids => [bd[1]],
          :open_hour   => 12,
          :open_minute => 45,
          :close_hour  => 13,
          :close_minute => 00
        }
        location.business_hours.build(attrs)

        # W, F
        attrs2 = {
          :business_day_ids => [bd[3], bd[5]],
          :open_hour   => 12,
          :open_minute => 45,
          :close_hour  => 13,
          :close_minute => 30
        }
        location.business_hours.build(attrs2)
      elsif location.name == "FabLab" && location.new_record?
        # M
        attrs = {
          :business_day_ids => [bd[1]],
          :open_hour   => 12,
          :open_minute => 45,
          :close_hour  => 13,
          :close_minute => 00
        }
        location.business_hours.build(attrs)

        # W, F
        attrs2 = {
          :business_day_ids => [bd[3], bd[5]],
          :open_hour   => 12,
          :open_minute => 45,
          :close_hour  => 13,
          :close_minute => 30
        }
        location.business_hours.build(attrs2)
      end
      location.save!
    end

    @logger.info "Successfully migrated #{ Location.count } locations"


    #
    # Migrate Equipment
    #

    puts "Migrating kits, and components..."
    @logger.info "==== KITS AND COMPONENTS ===="

    success_count = 0
    error_count = 0

    pb = ProgressBar.new(LegacyEquipment.count)

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

            kit                = Kit.new
            kit.location       = Location.find_or_create_by_name(le.legacy_location.loc_name)

            component.component_model = model_obj
            component.serial_number   = serial_number
            component.accessioned_at  = le.eq_date_entered
            component.cost            = cost
            component.budget          = budget


            if le.eq_removed
              component.deaccessioned_at = Time.local(1900, 1, 1, 0, 0, 0).to_datetime
            end

            kit.components << component

            if le.eq_removed
              kit.deaccession!
              raise "Kit not deaccessioned: #{ kit.halted_because.to_s }" if kit.halted?
            elsif le.circulating
              kit.circulate!
              raise "Kit not circulated: #{ kit.halted_because.to_s }" if kit.halted?
            else
              # default: non-circulating
            end

            if kit.save
              success_count += 1
            else
              error_count += 1
              @logger.error "Error saving #{ le.eq_uw_tag }:"
              @logger.error model_name.inspect
              @logger.error model_obj.inspect
              @logger.error component.errors.inspect
              @logger.error kit.errors.inspect
            end

          end
        rescue StandardError => e
          error_count += 1
          @logger.error "Error migrating #{le.eq_uw_tag}: #{ e }"
          @logger.error e.backtrace
        end
        pb.increment!
      end
    end

    @logger.info "Successfully migrated #{ success_count } asset tags, kits, and components"
    @logger.info "#{ error_count } errors"


    #
    # Create Covenants
    #

    puts "Creating covenants..."
    @logger.info "==== COVENANTS ===="

    sor = Covenant.create!(name:"Statement of Responsibility", description:'Users have signed and submitted the "Statement of Responsibility"')

    #
    # Migrate Users
    #

    puts "Migrating users..."
    @logger.info "==== USERS ===="

    success_count = 0
    error_count   = 0

    pb = ProgressBar.new(LegacyUser.count)

    LegacyUser.all.each do |lu|
      begin
        username = lu.client_id.gsub(/[^a-z0-9]/, "").strip
        name = lu.name.split(',')
        first_name = String.new
        last_name  = String.new
        if name.size > 1
          last_name = name.first.try(:strip)
          first_name = name.last.try(:strip)
        else
          name = lu.name.split(" ")
          last_name = name.pop.try(:strip)
          first_name = name.join(" ").try(:strip)
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
        u.disabled = true
        u.save!
        success_count += 1
      rescue StandardError => e
        error_count += 1
        @logger.error "Error migrating #{lu.client_id}: #{ e }"
        #puts e.backtrace
      end
      pb.increment!
    end

    @logger.info "Successfully migrated #{ success_count } users"
    @logger.info "#{ error_count } errors"


    #
    # Migrate Groups/Permissions
    #

    puts "Migrating groups and permissions..."
    @logger.info "==== GROUPS AND PERMISSIONS ===="

    group_success_count = 0
    permissions_success_count = 0
    users_success_count = 0
    error_count = 0

    pb = ProgressBar.new(LegacyGroup.count)

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
        @logger.error "Error migrating #{lg.group_id}: #{ e }"
        @logger.error e.backtrace
      end
      pb.increment!
    end

    @logger.info "Successfully migrated #{ group_success_count } groups"
    @logger.info "#{ permissions_success_count } permissions"
    @logger.info "#{ users_success_count } memberships"
    @logger.info "#{ error_count } errors"
  end


  desc 'migrate training data from dbx'
  task :training  => :init do

    Training.delete_all

    puts "Migrating training info..."
    @logger.info "==== TRAINING ===="

    success_count = 0
    error_count = 0

    LegacyTraining.all.each do |lt|
      c = Component.find_by_asset_tag(lt.eq_uw_tag.to_s)
      u = User.find_by_username(lt.client_id.downcase.squish)
      if c && u
        begin
          Training.first_or_create!(user: u, component_model: c.component_model)
        rescue StandardError => e
          error_count += 1
          @logger.error "Error migrating #{lt.special_id}: #{ e }"
#          puts e.backtrace
        end
        success_count += 1
      else
        @logger.error "Error migrating #{lt.special_id}: couldn't find component (#{lt.eq_uw_tag.to_s }) or user (#{lt.client_id})"
        error_count += 1
      end
    end

    @logger.info "Successfully migrated #{ success_count } trainings"
    @logger.info "#{ error_count } errors"
  end

  desc 'migrate check out and reservation data from dbx'
  task :loans  => :init do

    puts "Migrating checkouts and reservations..."
    success_count = 0
    error_count = 0

    puts "Clearing out loans table..."
    InventoryDetail.delete_all
    InventoryRecord.delete_all
    Loan.delete_all

    #
    # Migrate Checkouts/Reservations
    #

    #
    # Clean up the database a bit
    #

    puts "Cleaning up dirty data..."
    LegacyLoan.nullify_bogus_values!

    staff_group = Group.where(name: "DX-STAFF").first_or_create!

    LegacyLoan.pluck(:asset_tag).uniq.each do |tag|
      k = Kit.find_by_asset_tag(tag)
      if k
        unless k.groups.include?(staff_group)
          staff_group.kits << k
        end
      else
        @logger.error "-- Couldn't find asset tag: #{ tag }"
      end
    end
    staff_group.save!

    system_approver = User.unscoped.find_by_username("system")

    puts "Importing loans..."
    @logger.info "==== LOANS ===="

    pb      = ProgressBar.new(LegacyLoan.count)
    default = Settings.default_loan_duration

    importer_group = Group.where(name: "importer group").first_or_create!

    LegacyLoan.find_in_batches do |batch|
      batch.each do |ll|
        begin
          client_id = ll.client_id.downcase.gsub(/[^a-z0-9]/, "").strip
          client = User.find_by_username(client_id)
          raise "couldn't find reservation client: #{ client_id }" if client.nil?

          kit = Kit.find_by_asset_tag(ll.asset_tag)
          raise "couldn't find kit: #{ ll.asset_tag }" if kit.nil?

          unless kit.permissions_include? client
            importer_group.kits << kit unless importer_group.kits.include? kit
            importer_group.users << client unless importer_group.users.include? client
            importer_group.save!
          end

          l = Loan.new(client: client, kit: kit)

          l.starts_at = ll.starts_at.try(:to_datetime) || ll.out_at.try(:to_datetime)

          if l.starts_at > DateTime.current
            l.autofill_ends_at!
          else
            l.ends_at   = ll.ends_at.try(:to_datetime) || l.starts_at + default.days
          end

          if ll.check_out_attendant_id
            staffout_id   = ll.check_out_attendant_id.downcase.gsub(/[^a-z0-9]/, "").strip
            out_attendant = User.find_by_username(staffout_id)
          end

          if ll.check_in_attendant_id
            staffin_id    = ll.check_in_attendant_id.downcase.gsub(/[^a-z0-9]/, "").strip
            in_attendant  = User.find_by_username(staffin_id)
          end

          l.out_at      = ll.out_at.try(:to_datetime)
          l.in_at       = ll.in_at.try(:to_datetime)

          if out_attendant
            out_attendant.add_role(:attendant) unless out_attendant.attendant?
            l.new_check_out_inventory_record(attendant: out_attendant, kit: kit)
            l.check_out_inventory_record.inventory_details.each {|id| id.missing = false}
            l.check_out_inventory_record.created_at = l.out_at
          end

          if in_attendant
            in_attendant.add_role(:attendant) unless in_attendant.attendant?
            l.new_check_in_inventory_record(attendant: in_attendant, kit: kit)
            l.check_in_inventory_record.inventory_details.each {|id| id.missing = false}
            l.check_in_inventory_record.created_at = l.in_at
          end

          if in_attendant
            l.persist_workflow_state "checked_in"
          elsif out_attendant
            l.persist_workflow_state "checked_out"
            if l.client.disabled?
              l.client.disabled = false
              l.client.save
            end
          elsif l.starts_at
            if l.starts_at >= Date.today
              l.persist_workflow_state "requested"
              l.approver = system_approver
              if l.client.disabled?
                l.client.disabled = false
                l.client.save
              end
            else
              l.persist_workflow_state "canceled"
            end
          end

          if l.save
            success_count += 1
          else
            @logger.error "\n-- LOAN ERROR: #{ll.id}"
            @logger.error "#{ l.inspect }"
            if l.check_out_inventory_record
              @logger.error "#{ l.check_out_inventory_record.inspect }"
            end
            if l.check_in_inventory_record
              @logger.error "#{ l.check_in_inventory_record.inspect }"
            end
            @logger.error "#{ ll.inspect }"
            l.errors.messages.each {|k,v| @logger.error "#{ k.to_s.titleize } #{ v }" }
            error_count += 1
          end
        rescue StandardError => e
          error_count += 1
          @logger.error "\n-- LOAN ERROR: #{ll.id}: #{ e }"
          @logger.error ll.inspect
          @logger.error l.inspect
          @logger.error e.backtrace
        end
        pb.increment!
      end
    end

    @logger.info "Successfully migrated #{ success_count } of #{ LegacyLoan.count.to_s } loan"
    @logger.info "#{ error_count } errors"

  end

  desc 'migrate inventory data from dbx'
  task :inventory  => :init do

    puts "Migrating inventory records..."
    @logger.info "==== INVENTORY ===="

    success_count = 0
    error_count   = 0

    AuditInventoryRecord.destroy_all

    pb = ProgressBar.new(LegacyInventory.count)

    LegacyInventory.all.each do |li|
      component     = Component.find_by_asset_tag(li.eq_uw_tag.to_s)
      kit           = component.kit
      attendant     = User.find_by_username(li.staff_id)
      ir            = kit.audit_inventory_records.build(kit: kit, attendant: attendant)
      ir.created_at = li.date_inventoried

      ir.inventory_details_attributes = [{component_id: component.id, missing: false, created_at: li.date_inventoried }]

      if ir.save
        success_count += 1
      else
        @logger.error "Error migrating #{li.inventory_id}:"
        @logger.error "#{ li.inspect }"
        @logger.error "#{ ir.inspect }"
        ir.errors.messages.each {|k,v| @logger.error "#{ k.to_s.titleize } #{ v }" }
        error_count += 1
      end
      pb.increment!
    end

    @logger.info "Successfully migrated #{ success_count } of #{ LegacyInventory.count.to_s } inventory records"
    @logger.info "#{ error_count } errors"

  end

end


namespace :db do
  desc "fetch a current snapshot of dbx and do a full import into a fresh checkout db"
  task :mirror_dbx => ["dbx:fetch", "dbx:reload", "db:repop"]

  desc "drop, create, schema load, migrate (if needed), seed"
  task :rebuild => ["db:drop", "db:create", "db:schema:load", "db:migrate", "db:seed"]

  desc "drop, create, schema load, dbx:migrate"
  task :repop => ["db:rebuild", "dbx:migrate", "dbx:training", "dbx:res", "dbx:inventory"]

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
