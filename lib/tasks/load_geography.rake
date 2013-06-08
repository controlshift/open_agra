require 'csv'

desc "import geographic file eg. FILE=geographies.csv NAME=UKConstituencies"
task load_geography: :environment do
  csv_file = ENV['FILE']
  name = ENV['NAME']

  collection = GeographicCollection.find_or_create_by_name(name)
  collection.geographies.delete_all

  CSV.foreach csv_file, :headers => true do |row|

    kml  = row['kml']

    name     = kml.match(/<name>(.*)<\/name>/)[1]
    geometry =  kml.match(/<\/name>(.*)<\/Placemark>/m)[1].strip

    begin
      id = Geography.from_kml(geometry, name, collection.id)
      puts "Loaded #{name} into #{id}"
    rescue Exception => e
      puts e.inspect
    end
  end
end

task load_targets: :environment do
  csv_file = ENV['FILE']
  name = ENV['NAME']
  organisation_slug = ENV['ORGANISATION']

  organisation = Organisation.find_by_slug organisation_slug

  target_collection = TargetCollection.where(name: name, organisation_id: organisation.id).first

  if target_collection.nil?
    target_collection = TargetCollection.create(name: name, organisation: organisation)
  end

  target_collection.targets.delete_all
  geographic_collection = GeographicCollection.find_by_name('UK Parlimentary Constituencies')

  CSV.foreach csv_file, :headers => true do |row|
    geography = geographic_collection.geographies.find_by_name(row['const_name'])
    if geography
      puts "Loading #{row['mp_name']} into #{geography.name}"
      target = Target.new(name: "MP #{row['mp_name']}")
      target.geography = geography
      target.target_collection = target_collection
      target.organisation = organisation
      target.save!
    else
      puts "Could not find #{row['const_name']}"
    end
  end
end