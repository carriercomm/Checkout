desc 'migrate data from dbx2'
task :dbx2 => :environment do
  require 'tasks/legacy_classes'
  
  LegacyEquipment.dedupe!

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

end

