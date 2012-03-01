desc 'migrate data from dbx2'
task :dbx2 => :environment do
  require 'tasks/legacy_classes'

  #
  # Migrate Brands
  #

  LegacyEquipment.dedupe_brands!

  LegacyEquipment.all.each do |le|
    next if le.eq_manufacturer.nil?
    le.eq_manufacturer.strip!
    next if le.eq_manufacturer.nil? || le.eq_manufacturer.empty?
    begin
      brand = Brand.find_or_initialize_by_name(le.eq_manufacturer)
      if brand.new_record?
        if brand.save
          puts "Brand #{brand.id}:'#{ brand.name }' successfully created"
        else
          puts "error saving #{brand.id}:'#{ brand.name }'"
        end
      end
    rescue StandardError => e
      puts "Error migrating #{le.id}: #{ e }"
    end
  end

  #
  # Migrate Categories
  #

  LegacyCategories.all.each do |lc|
    lc.category.strip!

    begin
      cat = Category.find_or_initialize_by_name(lc.category)
      if cat.new_record?
        cat.description = lc.cat_notes
        if cat.save
          puts "Category #{cat.id}:'#{ cat.name }' successfully created"
        else
          puts "Error saving #{cat.id}:'#{ cat.name }'"
        end
      end
    rescue StandardError => e
      puts "Error migrating #{lc.category}: #{ e }"
    end    

  end

  #
  # Migrate Models
  #

  LegacyEquipment.normalize_special!

  LegacyEquipment.select(['eq_manufacturer', 'eq_model', 'eq_description', 'special', 'category'])
  .joins("LEFT OUTER JOIN eq_categories ON equipment.cat_id = eq_categories.cat_id")
  .group(['eq_manufacturer', 'eq_model'])
  .order(['eq_manufacturer', 'eq_model'])
  .each do |le|
    
    # puts le.eq_manufacturer.ljust(30) + " | " + le.eq_model.ljust(30) + " | " + (le.category.blank? ? "" : le.category)

    begin
      # look up the brand
      brand = Brand.find_by_name(le.eq_manufacturer)

      # normalize the model name
      model_name = le.eq_model.blank? ? "Unknown" : le.eq_model.strip

      # look up the model
      model_obj = brand.models.find_or_initialize_by_name(model_name)
      
      if model_obj.new_record?
        # set the description
        model_obj.description = le.eq_description

        # parse the training requirement
        training = false
        if !!le.special && le.special.downcase == 'yes'
          training = true
        end
        model_obj.training_required = training

        if model_obj.save
          puts "Model #{model_obj.id}:'#{ model_obj.name }' successfully created"
        else
          puts "Error saving #{model_obj.id}:'#{ model_obj.name }'"
        end
      end
    rescue StandardError => e
      puts "Error migrating #{le.eq_model}: #{ e }"
    end  

  end

  #
  # Migrate Budgets
  #

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
          puts "Budget #{budget.id}:    #{ budget.to_s } successfully created"
        else
          puts le.budget_number.ljust(30) + " | " + le.budget_name.ljust(30) + " | " + le.eq_budget_biennium
          puts "Error saving #{budget.id}:  #{ budget.to_s } #{ budget.errors.inspect.to_s }"
        end
      end
    rescue StandardError => e
      puts le.budget_number.ljust(30) + " | " + le.budget_name.ljust(30) + " | " + le.eq_budget_biennium
      puts "Error migrating #{le.budget_number}: #{ e }"
    end  

  end
  
  #
  # Migrate Parts
  #
  
  LegacyEquipment.includes(:legacy_budget).all.each do |le|

    begin
      # look up the brand
      brand = Brand.find_by_name(le.eq_manufacturer)

      # look up the model
      model_name = le.eq_model.blank? ? "Unknown" : le.eq_model.strip
      model_obj = brand.models.find_by_name(model_name)
      
      # look up the budget
      le.legacy_budget.budget_number.strip!       unless le.legacy_budget.budget_number.nil?
      le.legacy_budget.budget_name.strip!         unless le.legacy_budget.budget_name.nil?
      le.eq_budget_biennium.strip!  unless le.eq_budget_biennium.nil?
      
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
      asset_tag = AssetTag.where(:uid => le.eq_uw_tag).includes(:part).first_or_initialize

      # TODO: add kit/bundle

      if asset_tag.new_record? || asset_tag.part.nil?
        # start building up the part attrs
        serial_number = (le.eq_serial_num.nil? || le.eq_serial_num.strip!.blank?) ? nil : le.eq_serial_num
        cost          = (le.eq_cost == 0) ? nil : le.eq_cost
        insured       = (le.eq_insured.strip.downcase == "on") ? true : false
        missing       = (le.eq_removed.strip.downcase == "on") ? true : false

        part = Part.new
        part.cost    = cost
        part.insured = insured
        part.missing = missing
        part.model   = model_obj
        part.budget  = budget
        
        asset_tag.part = part
        
        if asset_tag.save
          puts "Asset_Tag #{ asset_tag.id }:'#{ asset_tag.uid }' successfully created"
          puts "Part #{ part.id }:'#{ part.serial_number }' successfully created"
        else
          puts "Error saving #{ asset_tag.id }:'#{ asset_tag.uid }'"
          puts "Error saving #{ part.id }:'#{ part.serial_number }'"
        end

      end
    rescue StandardError => e
      puts "Error migrating #{le.eq_uw_tag}: #{ e }"
    end  
  end
end

namespace :db do
  desc "drop, create, migrate"
  task :rebuild => ["db:drop", "db:create", "db:migrate"]
end
