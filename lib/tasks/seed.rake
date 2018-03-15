namespace :db do
  desc "Loads seed data from db/fixtures for the current environment."
  task :seed => :environment do

    seeding_files = Dir[File.join(Rails.root, "db/fixtures", Rails.env, '*.rb')]
    seeding_files = Dir[File.join(Rails.root, "db/fixtures/default", '*.rb')] if seeding_files.empty?

    seeding_files..sort.each { |fixture|
      puts "\n== [#{Rails.env}] Seeding from #{File.split(fixture).last} " + ("=" * (60 - (20 + File.split(fixture).last.length + Rails.env.length)))
      load fixture
      puts "=" * 60 + "\n"
    }
  end
end
