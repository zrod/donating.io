namespace :places do
  desc "Generate random places for testing - Usage: rake 'places:generate[number_of_places]'"
  task :generate, [:count] => :environment do |task, args|
    count = (args[:count] || 10).to_i

    puts "Generating #{count} random places..."

    if Category.count == 0
      puts "No categories found. Please run: rake db:seed"
      exit
    end

    if Country.count == 0
      puts "No countries found. Please run: rake db:seed"
      exit
    end

    if User.count == 0
      puts "No users found. Creating a test user..."
      User.create!(
        username: "test_user_#{SecureRandom.hex(4)}",
        email_address: "test@example.com",
        password: "password123",
        password_confirmation: "password123"
      )
    end

    place_names = [
      "Community Donation Center", "Local Charity Hub", "Goodwill Drop-off",
      "Salvation Army Store", "Red Cross Collection Point", "Food Bank Distribution",
      "Clothing Donation Box", "Electronics Recycling Center", "Book Donation Library",
      "Furniture Exchange", "Toy Collection Center", "Pet Supply Donations",
      "Medical Equipment Exchange", "School Supply Drive", "Sports Equipment Donations"
    ]

    cities = [
      "Toronto", "Vancouver", "Montreal", "Calgary", "Edmonton", "Ottawa", "Winnipeg",
      "Quebec City", "Hamilton", "Kitchener", "London", "Victoria", "Halifax",
      "New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia",
      "San Antonio", "San Diego", "Dallas", "San Jose", "Austin", "Jacksonville"
    ]

    regions = {
      "Toronto" => "Ontario", "Vancouver" => "British Columbia", "Montreal" => "Quebec",
      "Calgary" => "Alberta", "Edmonton" => "Alberta", "Ottawa" => "Ontario",
      "New York" => "New York", "Los Angeles" => "California", "Chicago" => "Illinois"
    }

    created_count = 0

    count.times do |i|
      begin
        city = cities.sample
        region = regions[city] || ["Ontario", "California", "Texas", "New York"].sample

        place = Place.new(
          name: "#{place_names.sample} #{rand(1..999)}",
          description: generate_description,
          address: generate_address,
          city: city,
          region: region,
          postal_code: generate_postal_code,
          lat: rand(-90.0..90.0).round(6),
          lng: rand(-180.0..180.0).round(6),
          phone: generate_phone,
          email: rand < 0.7 ? generate_email : nil,
          url: rand < 0.5 ? generate_url : nil,
          pickup: [true, false].sample,
          used_ok: [true, false].sample,
          is_bin: [true, false].sample,
          tax_receipt: [true, false].sample,
          charity_support: rand < 0.6 ? generate_charity_support : nil,
          location_instructions: rand < 0.4 ? generate_location_instructions : nil,
          osm_id: rand(1000..999999),
          status: Place::STATUSES[:published],
          user: User.all.sample,
          country: Country.where(active: true).sample || Country.all.sample
        )

        categories = Category.all.sample(rand(1..3))
        categories.each do |category|
          place.categories_places.build(category: category)
        end

        if place.save
          place.update_column(:status, Place::STATUSES[:published])

          generate_place_hours(place) if rand < 0.8

          created_count += 1
          print "."
        else
          puts "\nFailed to create place #{i + 1}: #{place.errors.full_messages.join(', ')}"
        end

      rescue => e
        puts "\nError creating place #{i + 1}: #{e.message}"
      end
    end

    puts "\n\nSuccessfully created #{created_count} out of #{count} places!"
    puts "Total places in database: #{Place.count}"
    puts "Published places: #{Place.published.count}"
  end

  private

  def generate_description
    descriptions = [
      "A community-focused donation center accepting various household items.",
      "Local charity organization supporting families in need.",
      "Drop-off location for gently used clothing and accessories.",
      "Collection point for books, toys, and educational materials.",
      "Donation center specializing in furniture and home goods.",
      "Community hub for collecting food and essential supplies.",
      "Charity bin accepting electronics and small appliances.",
      "Local organization supporting homeless shelter initiatives.",
      "Donation center with focus on children and family items.",
      "Community collection point for sports and recreational equipment."
    ]
    descriptions.sample
  end

  def generate_address
    street_numbers = rand(1..9999)
    street_names = [
      "Main Street", "First Avenue", "Oak Street", "Maple Drive", "King Street",
      "Queen Street", "Park Avenue", "Church Street", "Mill Road", "High Street",
      "Victoria Street", "Union Street", "College Street", "Bay Street", "Elm Street"
    ]
    "#{street_numbers} #{street_names.sample}"
  end

  def generate_postal_code
    if rand < 0.6
      "#{('A'..'Z').to_a.sample}#{rand(0..9)}#{('A'..'Z').to_a.sample} #{rand(0..9)}#{('A'..'Z').to_a.sample}#{rand(0..9)}"
    else
      "#{rand(10000..99999)}"
    end
  end

  def generate_phone
    area_codes = ["416", "647", "437", "905", "613", "514", "604", "778", "403", "780"]
    "#{area_codes.sample}-#{rand(100..999)}-#{rand(1000..9999)}"
  end

  def generate_email
    domains = ["gmail.com", "charity.org", "donations.ca", "community.org", "goodwill.org"]
    username = "contact#{rand(100..999)}"
    "#{username}@#{domains.sample}"
  end

  def generate_url
    base_urls = ["donationscenter", "charity", "community", "goodwill", "help"]
    "https://#{base_urls.sample}#{rand(1..99)}.org"
  end

  def generate_charity_support
    supports = [
      "Donated items support local homeless shelters",
      "Proceeds go to community food bank",
      "Items distributed to families in need",
      "Support for single mothers and children",
      "Funding for local educational programs",
      "Items sold to support youth programs"
    ]
    supports.sample
  end

  def generate_location_instructions
    instructions = [
      "Drop-off available during business hours at main entrance",
      "Use side door for donations after hours",
      "Ring bell at loading dock for large items",
      "Donations accepted at reception desk",
      "Leave items in designated area near parking lot",
      "Staff available to assist with unloading large donations"
    ]
    instructions.sample
  end

  def generate_place_hours(place)
    days_with_hours = (1..7).to_a.sample(rand(1..7))

    days_with_hours.each do |day|
      opening_hour = [800, 900, 1000].sample
      closing_hour = [1600, 1700, 1800, 1900, 2000].sample

      place.place_hours.create!(
        day_of_week: day,
        from_hour: opening_hour,
        to_hour: closing_hour
      )
    end
  end
end
