desc 'migrate data from dbx2'
task :dbx2 => :environment do
  require 'tasks/legacy_classes'

  #
  # Migrate Makers
  #

  LegacyEquipment.dedupe_makers!

  LegacyEquipment.all.each do |le|
    next if le.eq_manufacturer.nil?
    le.eq_manufacturer.strip!
    next if le.eq_manufacturer.nil? || le.eq_manufacturer.empty?
    begin
      maker = Checkout::Maker.find_or_initialize_by_name(le.eq_manufacturer)
      if maker.new_record?
        if maker.save
          puts "Maker #{maker.id}:'#{ maker.name }' successfully created"
        else
          puts "error saving #{maker.id}:'#{ maker.name }'"
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
      cat = Checkout::Category.find_or_initialize_by_name(lc.category)
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
      # look up the maker
      maker = Checkout::Maker.find_by_name(le.eq_manufacturer)

      # normalize the model name
      model_name = le.eq_model.blank? ? "Unknown" : le.eq_model.strip

      # look up the model
      model_obj = maker.models.find_or_initialize_by_name(model_name)
      
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

  


end
