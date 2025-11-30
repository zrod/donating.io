return if Rails.env.test?

puts 'seeding country subdivisions'

usa = Country.find_by!(iso_alpha3: 'USA')
canada = Country.find_by!(iso_alpha3: 'CAN')

us_states = [
  { name: 'Alabama', code: 'AL', subdivision_type: 'State' },
  { name: 'Alaska', code: 'AK', subdivision_type: 'State' },
  { name: 'Arizona', code: 'AZ', subdivision_type: 'State' },
  { name: 'Arkansas', code: 'AR', subdivision_type: 'State' },
  { name: 'California', code: 'CA', subdivision_type: 'State' },
  { name: 'Colorado', code: 'CO', subdivision_type: 'State' },
  { name: 'Connecticut', code: 'CT', subdivision_type: 'State' },
  { name: 'Delaware', code: 'DE', subdivision_type: 'State' },
  { name: 'Florida', code: 'FL', subdivision_type: 'State' },
  { name: 'Georgia', code: 'GA', subdivision_type: 'State' },
  { name: 'Hawaii', code: 'HI', subdivision_type: 'State' },
  { name: 'Idaho', code: 'ID', subdivision_type: 'State' },
  { name: 'Illinois', code: 'IL', subdivision_type: 'State' },
  { name: 'Indiana', code: 'IN', subdivision_type: 'State' },
  { name: 'Iowa', code: 'IA', subdivision_type: 'State' },
  { name: 'Kansas', code: 'KS', subdivision_type: 'State' },
  { name: 'Kentucky', code: 'KY', subdivision_type: 'State' },
  { name: 'Louisiana', code: 'LA', subdivision_type: 'State' },
  { name: 'Maine', code: 'ME', subdivision_type: 'State' },
  { name: 'Maryland', code: 'MD', subdivision_type: 'State' },
  { name: 'Massachusetts', code: 'MA', subdivision_type: 'State' },
  { name: 'Michigan', code: 'MI', subdivision_type: 'State' },
  { name: 'Minnesota', code: 'MN', subdivision_type: 'State' },
  { name: 'Mississippi', code: 'MS', subdivision_type: 'State' },
  { name: 'Missouri', code: 'MO', subdivision_type: 'State' },
  { name: 'Montana', code: 'MT', subdivision_type: 'State' },
  { name: 'Nebraska', code: 'NE', subdivision_type: 'State' },
  { name: 'Nevada', code: 'NV', subdivision_type: 'State' },
  { name: 'New Hampshire', code: 'NH', subdivision_type: 'State' },
  { name: 'New Jersey', code: 'NJ', subdivision_type: 'State' },
  { name: 'New Mexico', code: 'NM', subdivision_type: 'State' },
  { name: 'New York', code: 'NY', subdivision_type: 'State' },
  { name: 'North Carolina', code: 'NC', subdivision_type: 'State' },
  { name: 'North Dakota', code: 'ND', subdivision_type: 'State' },
  { name: 'Ohio', code: 'OH', subdivision_type: 'State' },
  { name: 'Oklahoma', code: 'OK', subdivision_type: 'State' },
  { name: 'Oregon', code: 'OR', subdivision_type: 'State' },
  { name: 'Pennsylvania', code: 'PA', subdivision_type: 'State' },
  { name: 'Rhode Island', code: 'RI', subdivision_type: 'State' },
  { name: 'South Carolina', code: 'SC', subdivision_type: 'State' },
  { name: 'South Dakota', code: 'SD', subdivision_type: 'State' },
  { name: 'Tennessee', code: 'TN', subdivision_type: 'State' },
  { name: 'Texas', code: 'TX', subdivision_type: 'State' },
  { name: 'Utah', code: 'UT', subdivision_type: 'State' },
  { name: 'Vermont', code: 'VT', subdivision_type: 'State' },
  { name: 'Virginia', code: 'VA', subdivision_type: 'State' },
  { name: 'Washington', code: 'WA', subdivision_type: 'State' },
  { name: 'West Virginia', code: 'WV', subdivision_type: 'State' },
  { name: 'Wisconsin', code: 'WI', subdivision_type: 'State' },
  { name: 'Wyoming', code: 'WY', subdivision_type: 'State' },
  { name: 'District of Columbia', code: 'DC', subdivision_type: 'District' }
]

canadian_subdivisions = [
  { name: 'Alberta', code: 'AB', subdivision_type: 'Province' },
  { name: 'British Columbia', code: 'BC', subdivision_type: 'Province' },
  { name: 'Manitoba', code: 'MB', subdivision_type: 'Province' },
  { name: 'New Brunswick', code: 'NB', subdivision_type: 'Province' },
  { name: 'Newfoundland and Labrador', code: 'NL', subdivision_type: 'Province' },
  { name: 'Nova Scotia', code: 'NS', subdivision_type: 'Province' },
  { name: 'Ontario', code: 'ON', subdivision_type: 'Province' },
  { name: 'Prince Edward Island', code: 'PE', subdivision_type: 'Province' },
  { name: 'Quebec', code: 'QC', subdivision_type: 'Province' },
  { name: 'Saskatchewan', code: 'SK', subdivision_type: 'Province' },
  { name: 'Northwest Territories', code: 'NT', subdivision_type: 'Territory' },
  { name: 'Nunavut', code: 'NU', subdivision_type: 'Territory' },
  { name: 'Yukon', code: 'YT', subdivision_type: 'Territory' }
]

us_states.each do |attrs|
  CountrySubdivision.find_or_create_by!(country: usa, code: attrs[:code]) do |subdivision|
    subdivision.name = attrs[:name]
    subdivision.subdivision_type = attrs[:subdivision_type]
  end
end

canadian_subdivisions.each do |attrs|
  CountrySubdivision.find_or_create_by!(country: canada, code: attrs[:code]) do |subdivision|
    subdivision.name = attrs[:name]
    subdivision.subdivision_type = attrs[:subdivision_type]
  end
end
