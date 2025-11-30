namespace :db do
  namespace :seed do
    Dir[Rails.root.join("db/seeds/*.rb")].each do |file|
      task_name = File.basename(file, ".rb")

      desc "Load seed data from db/seeds/#{task_name}.rb"
      task task_name.to_sym => :environment do
        puts "Seeding #{task_name}..."
        load file
        puts "Done."
      end
    end
  end
end
