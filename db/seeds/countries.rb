return if Rails.env.test?

puts 'seeding countries'

Country.create!(
  [
    {
      "name": "Afghanistan",
      "iso_alpha3": "AFG"
    },
    {
      "name": "Åland Islands",
      "iso_alpha3": "ALA"
    },
    {
      "name": "Albania",
      "iso_alpha3": "ALB"
    },
    {
      "name": "Algeria",
      "iso_alpha3": "DZA"
    },
    {
      "name": "American Samoa",
      "iso_alpha3": "ASM"
    },
    {
      "name": "Andorra",
      "iso_alpha3": "AND"
    },
    {
      "name": "Angola",
      "iso_alpha3": "AGO"
    },
    {
      "name": "Anguilla",
      "iso_alpha3": "AIA"
    },
    {
      "name": "Antarctica",
      "iso_alpha3": "ATA"
    },
    {
      "name": "Antigua and Barbuda",
      "iso_alpha3": "ATG"
    },
    {
      "name": "Argentina",
      "iso_alpha3": "ARG",
      "active": true
    },
    {
      "name": "Armenia",
      "iso_alpha3": "ARM"
    },
    {
      "name": "Aruba",
      "iso_alpha3": "ABW"
    },
    {
      "name": "Australia",
      "iso_alpha3": "AUS"
    },
    {
      "name": "Austria",
      "iso_alpha3": "AUT"
    },
    {
      "name": "Azerbaijan",
      "iso_alpha3": "AZE"
    },
    {
      "name": "Bahamas",
      "iso_alpha3": "BHS",
      "active": true
    },
    {
      "name": "Bahrain",
      "iso_alpha3": "BHR"
    },
    {
      "name": "Bangladesh",
      "iso_alpha3": "BGD"
    },
    {
      "name": "Barbados",
      "iso_alpha3": "BRB"
    },
    {
      "name": "Belarus",
      "iso_alpha3": "BLR"
    },
    {
      "name": "Belgium",
      "iso_alpha3": "BEL"
    },
    {
      "name": "Belize",
      "iso_alpha3": "BLZ",
      "active": true
    },
    {
      "name": "Benin",
      "iso_alpha3": "BEN"
    },
    {
      "name": "Bermuda",
      "iso_alpha3": "BMU",
      "active": true
    },
    {
      "name": "Bhutan",
      "iso_alpha3": "BTN"
    },
    {
      "name": "Bolivia (Plurinational State of)",
      "iso_alpha3": "BOL",
      "active": true
    },
    {
      "name": "Bonaire, Sint Eustatius and Saba",
      "iso_alpha3": "BES"
    },
    {
      "name": "Bosnia and Herzegovina",
      "iso_alpha3": "BIH"
    },
    {
      "name": "Botswana",
      "iso_alpha3": "BWA"
    },
    {
      "name": "Bouvet Island",
      "iso_alpha3": "BVT"
    },
    {
      "name": "Brazil",
      "iso_alpha3": "BRA",
      "weight": 51,
      "active": true
    },
    {
      "name": "British Indian Ocean Territory",
      "iso_alpha3": "IOT"
    },
    {
      "name": "Brunei Darussalam",
      "iso_alpha3": "BRN"
    },
    {
      "name": "Bulgaria",
      "iso_alpha3": "BGR"
    },
    {
      "name": "Burkina Faso",
      "iso_alpha3": "BFA"
    },
    {
      "name": "Burundi",
      "iso_alpha3": "BDI"
    },
    {
      "name": "Cabo Verde",
      "iso_alpha3": "CPV"
    },
    {
      "name": "Cambodia",
      "iso_alpha3": "KHM"
    },
    {
      "name": "Cameroon",
      "iso_alpha3": "CMR"
    },
    {
      "name": "Canada",
      "iso_alpha3": "CAN",
      "weight": 100,
      "active": true
    },
    {
      "name": "Cayman Islands",
      "iso_alpha3": "CYM"
    },
    {
      "name": "Central African Republic",
      "iso_alpha3": "CAF"
    },
    {
      "name": "Chad",
      "iso_alpha3": "TCD"
    },
    {
      "name": "Chile",
      "iso_alpha3": "CHL",
      "active": true
    },
    {
      "name": "China",
      "iso_alpha3": "CHN"
    },
    {
      "name": "Christmas Island",
      "iso_alpha3": "CXR"
    },
    {
      "name": "Cocos (Keeling) Islands",
      "iso_alpha3": "CCK"
    },
    {
      "name": "Colombia",
      "iso_alpha3": "COL",
      "active": true
    },
    {
      "name": "Comoros",
      "iso_alpha3": "COM"
    },
    {
      "name": "Congo",
      "iso_alpha3": "COG"
    },
    {
      "name": "Congo (Democratic Republic of the)",
      "iso_alpha3": "COD"
    },
    {
      "name": "Cook Islands",
      "iso_alpha3": "COK"
    },
    {
      "name": "Costa Rica",
      "iso_alpha3": "CRI",
      "active": true
    },
    {
      "name": "Côte d'Ivoire",
      "iso_alpha3": "CIV"
    },
    {
      "name": "Croatia",
      "iso_alpha3": "HRV"
    },
    {
      "name": "Cuba",
      "iso_alpha3": "CUB"
    },
    {
      "name": "Curaçao",
      "iso_alpha3": "CUW"
    },
    {
      "name": "Cyprus",
      "iso_alpha3": "CYP"
    },
    {
      "name": "Czechia",
      "iso_alpha3": "CZE"
    },
    {
      "name": "Denmark",
      "iso_alpha3": "DNK"
    },
    {
      "name": "Djibouti",
      "iso_alpha3": "DJI"
    },
    {
      "name": "Dominica",
      "iso_alpha3": "DMA"
    },
    {
      "name": "Dominican Republic",
      "iso_alpha3": "DOM"
    },
    {
      "name": "Ecuador",
      "iso_alpha3": "ECU",
      "active": true
    },
    {
      "name": "Egypt",
      "iso_alpha3": "EGY"
    },
    {
      "name": "El Salvador",
      "iso_alpha3": "SLV",
      "active": true
    },
    {
      "name": "Equatorial Guinea",
      "iso_alpha3": "GNQ"
    },
    {
      "name": "Eritrea",
      "iso_alpha3": "ERI"
    },
    {
      "name": "Estonia",
      "iso_alpha3": "EST"
    },
    {
      "name": "Eswatini",
      "iso_alpha3": "SWZ"
    },
    {
      "name": "Ethiopia",
      "iso_alpha3": "ETH"
    },
    {
      "name": "Falkland Islands (Malvinas)",
      "iso_alpha3": "FLK"
    },
    {
      "name": "Faroe Islands",
      "iso_alpha3": "FRO"
    },
    {
      "name": "Fiji",
      "iso_alpha3": "FJI"
    },
    {
      "name": "Finland",
      "iso_alpha3": "FIN"
    },
    {
      "name": "France",
      "iso_alpha3": "FRA"
    },
    {
      "name": "French Guiana",
      "iso_alpha3": "GUF"
    },
    {
      "name": "French Polynesia",
      "iso_alpha3": "PYF"
    },
    {
      "name": "French Southern Territories",
      "iso_alpha3": "ATF"
    },
    {
      "name": "Gabon",
      "iso_alpha3": "GAB"
    },
    {
      "name": "Gambia",
      "iso_alpha3": "GMB"
    },
    {
      "name": "Georgia",
      "iso_alpha3": "GEO"
    },
    {
      "name": "Germany",
      "iso_alpha3": "DEU"
    },
    {
      "name": "Ghana",
      "iso_alpha3": "GHA"
    },
    {
      "name": "Gibraltar",
      "iso_alpha3": "GIB"
    },
    {
      "name": "Greece",
      "iso_alpha3": "GRC"
    },
    {
      "name": "Greenland",
      "iso_alpha3": "GRL"
    },
    {
      "name": "Grenada",
      "iso_alpha3": "GRD"
    },
    {
      "name": "Guadeloupe",
      "iso_alpha3": "GLP"
    },
    {
      "name": "Guam",
      "iso_alpha3": "GUM"
    },
    {
      "name": "Guatemala",
      "iso_alpha3": "GTM"
    },
    {
      "name": "Guernsey",
      "iso_alpha3": "GGY"
    },
    {
      "name": "Guinea",
      "iso_alpha3": "GIN"
    },
    {
      "name": "Guinea-Bissau",
      "iso_alpha3": "GNB"
    },
    {
      "name": "Guyana",
      "iso_alpha3": "GUY",
      "active": true
    },
    {
      "name": "Haiti",
      "iso_alpha3": "HTI",
      "active": true
    },
    {
      "name": "Heard Island and McDonald Islands",
      "iso_alpha3": "HMD"
    },
    {
      "name": "Holy See",
      "iso_alpha3": "VAT"
    },
    {
      "name": "Honduras",
      "iso_alpha3": "HND",
      "active": true
    },
    {
      "name": "Hong Kong",
      "iso_alpha3": "HKG"
    },
    {
      "name": "Hungary",
      "iso_alpha3": "HUN"
    },
    {
      "name": "Iceland",
      "iso_alpha3": "ISL"
    },
    {
      "name": "India",
      "iso_alpha3": "IND"
    },
    {
      "name": "Indonesia",
      "iso_alpha3": "IDN"
    },
    {
      "name": "Iran (Islamic Republic of)",
      "iso_alpha3": "IRN"
    },
    {
      "name": "Iraq",
      "iso_alpha3": "IRQ"
    },
    {
      "name": "Ireland",
      "iso_alpha3": "IRL"
    },
    {
      "name": "Isle of Man",
      "iso_alpha3": "IMN"
    },
    {
      "name": "Israel",
      "iso_alpha3": "ISR"
    },
    {
      "name": "Italy",
      "iso_alpha3": "ITA"
    },
    {
      "name": "Jamaica",
      "iso_alpha3": "JAM",
      "active": true
    },
    {
      "name": "Japan",
      "iso_alpha3": "JPN"
    },
    {
      "name": "Jersey",
      "iso_alpha3": "JEY"
    },
    {
      "name": "Jordan",
      "iso_alpha3": "JOR"
    },
    {
      "name": "Kazakhstan",
      "iso_alpha3": "KAZ"
    },
    {
      "name": "Kenya",
      "iso_alpha3": "KEN"
    },
    {
      "name": "Kiribati",
      "iso_alpha3": "KIR"
    },
    {
      "name": "Korea (Democratic People's Republic of)",
      "iso_alpha3": "PRK"
    },
    {
      "name": "Korea (Republic of)",
      "iso_alpha3": "KOR"
    },
    {
      "name": "Kuwait",
      "iso_alpha3": "KWT"
    },
    {
      "name": "Kyrgyzstan",
      "iso_alpha3": "KGZ"
    },
    {
      "name": "Lao People's Democratic Republic",
      "iso_alpha3": "LAO"
    },
    {
      "name": "Latvia",
      "iso_alpha3": "LVA"
    },
    {
      "name": "Lebanon",
      "iso_alpha3": "LBN"
    },
    {
      "name": "Lesotho",
      "iso_alpha3": "LSO"
    },
    {
      "name": "Liberia",
      "iso_alpha3": "LBR"
    },
    {
      "name": "Libya",
      "iso_alpha3": "LBY"
    },
    {
      "name": "Liechtenstein",
      "iso_alpha3": "LIE"
    },
    {
      "name": "Lithuania",
      "iso_alpha3": "LTU"
    },
    {
      "name": "Luxembourg",
      "iso_alpha3": "LUX"
    },
    {
      "name": "Macao",
      "iso_alpha3": "MAC"
    },
    {
      "name": "Macedonia (the former Yugoslav Republic of)",
      "iso_alpha3": "MKD"
    },
    {
      "name": "Madagascar",
      "iso_alpha3": "MDG"
    },
    {
      "name": "Malawi",
      "iso_alpha3": "MWI"
    },
    {
      "name": "Malaysia",
      "iso_alpha3": "MYS"
    },
    {
      "name": "Maldives",
      "iso_alpha3": "MDV"
    },
    {
      "name": "Mali",
      "iso_alpha3": "MLI"
    },
    {
      "name": "Malta",
      "iso_alpha3": "MLT"
    },
    {
      "name": "Marshall Islands",
      "iso_alpha3": "MHL"
    },
    {
      "name": "Martinique",
      "iso_alpha3": "MTQ"
    },
    {
      "name": "Mauritania",
      "iso_alpha3": "MRT"
    },
    {
      "name": "Mauritius",
      "iso_alpha3": "MUS"
    },
    {
      "name": "Mayotte",
      "iso_alpha3": "MYT"
    },
    {
      "name": "Mexico",
      "iso_alpha3": "MEX",
      "active": true
    },
    {
      "name": "Micronesia (Federated States of)",
      "iso_alpha3": "FSM"
    },
    {
      "name": "Moldova (Republic of)",
      "iso_alpha3": "MDA"
    },
    {
      "name": "Monaco",
      "iso_alpha3": "MCO"
    },
    {
      "name": "Mongolia",
      "iso_alpha3": "MNG"
    },
    {
      "name": "Montenegro",
      "iso_alpha3": "MNE"
    },
    {
      "name": "Montserrat",
      "iso_alpha3": "MSR"
    },
    {
      "name": "Morocco",
      "iso_alpha3": "MAR"
    },
    {
      "name": "Mozambique",
      "iso_alpha3": "MOZ"
    },
    {
      "name": "Myanmar",
      "iso_alpha3": "MMR"
    },
    {
      "name": "Namibia",
      "iso_alpha3": "NAM"
    },
    {
      "name": "Nauru",
      "iso_alpha3": "NRU"
    },
    {
      "name": "Nepal",
      "iso_alpha3": "NPL"
    },
    {
      "name": "Netherlands",
      "iso_alpha3": "NLD"
    },
    {
      "name": "New Caledonia",
      "iso_alpha3": "NCL"
    },
    {
      "name": "New Zealand",
      "iso_alpha3": "NZL"
    },
    {
      "name": "Nicaragua",
      "iso_alpha3": "NIC",
      "active": true
    },
    {
      "name": "Niger",
      "iso_alpha3": "NER"
    },
    {
      "name": "Nigeria",
      "iso_alpha3": "NGA"
    },
    {
      "name": "Niue",
      "iso_alpha3": "NIU"
    },
    {
      "name": "Norfolk Island",
      "iso_alpha3": "NFK"
    },
    {
      "name": "Northern Mariana Islands",
      "iso_alpha3": "MNP"
    },
    {
      "name": "Norway",
      "iso_alpha3": "NOR"
    },
    {
      "name": "Oman",
      "iso_alpha3": "OMN"
    },
    {
      "name": "Pakistan",
      "iso_alpha3": "PAK"
    },
    {
      "name": "Palau",
      "iso_alpha3": "PLW"
    },
    {
      "name": "Palestine, State of",
      "iso_alpha3": "PSE"
    },
    {
      "name": "Panama",
      "iso_alpha3": "PAN",
      "active": true
    },
    {
      "name": "Papua New Guinea",
      "iso_alpha3": "PNG"
    },
    {
      "name": "Paraguay",
      "iso_alpha3": "PRY",
      "active": true
    },
    {
      "name": "Peru",
      "iso_alpha3": "PER",
      "active": true
    },
    {
      "name": "Philippines",
      "iso_alpha3": "PHL"
    },
    {
      "name": "Pitcairn",
      "iso_alpha3": "PCN"
    },
    {
      "name": "Poland",
      "iso_alpha3": "POL"
    },
    {
      "name": "Portugal",
      "iso_alpha3": "PRT"
    },
    {
      "name": "Puerto Rico",
      "iso_alpha3": "PRI",
      "active": true
    },
    {
      "name": "Qatar",
      "iso_alpha3": "QAT"
    },
    {
      "name": "Réunion",
      "iso_alpha3": "REU"
    },
    {
      "name": "Romania",
      "iso_alpha3": "ROU"
    },
    {
      "name": "Russian Federation",
      "iso_alpha3": "RUS"
    },
    {
      "name": "Rwanda",
      "iso_alpha3": "RWA"
    },
    {
      "name": "Saint Barthélemy",
      "iso_alpha3": "BLM"
    },
    {
      "name": "Saint Helena, Ascension and Tristan da Cunha",
      "iso_alpha3": "SHN"
    },
    {
      "name": "Saint Kitts and Nevis",
      "iso_alpha3": "KNA"
    },
    {
      "name": "Saint Lucia",
      "iso_alpha3": "LCA"
    },
    {
      "name": "Saint Martin (French part)",
      "iso_alpha3": "MAF"
    },
    {
      "name": "Saint Pierre and Miquelon",
      "iso_alpha3": "SPM"
    },
    {
      "name": "Saint Vincent and the Grenadines",
      "iso_alpha3": "VCT"
    },
    {
      "name": "Samoa",
      "iso_alpha3": "WSM"
    },
    {
      "name": "San Marino",
      "iso_alpha3": "SMR"
    },
    {
      "name": "Sao Tome and Principe",
      "iso_alpha3": "STP"
    },
    {
      "name": "Saudi Arabia",
      "iso_alpha3": "SAU"
    },
    {
      "name": "Senegal",
      "iso_alpha3": "SEN"
    },
    {
      "name": "Serbia",
      "iso_alpha3": "SRB"
    },
    {
      "name": "Seychelles",
      "iso_alpha3": "SYC"
    },
    {
      "name": "Sierra Leone",
      "iso_alpha3": "SLE"
    },
    {
      "name": "Singapore",
      "iso_alpha3": "SGP"
    },
    {
      "name": "Sint Maarten (Dutch part)",
      "iso_alpha3": "SXM"
    },
    {
      "name": "Slovakia",
      "iso_alpha3": "SVK"
    },
    {
      "name": "Slovenia",
      "iso_alpha3": "SVN"
    },
    {
      "name": "Solomon Islands",
      "iso_alpha3": "SLB"
    },
    {
      "name": "Somalia",
      "iso_alpha3": "SOM"
    },
    {
      "name": "South Africa",
      "iso_alpha3": "ZAF"
    },
    {
      "name": "South Georgia and the South Sandwich Islands",
      "iso_alpha3": "SGS"
    },
    {
      "name": "South Sudan",
      "iso_alpha3": "SSD"
    },
    {
      "name": "Spain",
      "iso_alpha3": "ESP"
    },
    {
      "name": "Sri Lanka",
      "iso_alpha3": "LKA"
    },
    {
      "name": "Sudan",
      "iso_alpha3": "SDN"
    },
    {
      "name": "Suriname",
      "iso_alpha3": "SUR",
      "active": true
    },
    {
      "name": "Svalbard and Jan Mayen",
      "iso_alpha3": "SJM"
    },
    {
      "name": "Sweden",
      "iso_alpha3": "SWE"
    },
    {
      "name": "Switzerland",
      "iso_alpha3": "CHE"
    },
    {
      "name": "Syrian Arab Republic",
      "iso_alpha3": "SYR"
    },
    {
      "name": "Taiwan, Province of China",
      "iso_alpha3": "TWN"
    },
    {
      "name": "Tajikistan",
      "iso_alpha3": "TJK"
    },
    {
      "name": "Tanzania, United Republic of",
      "iso_alpha3": "TZA"
    },
    {
      "name": "Thailand",
      "iso_alpha3": "THA"
    },
    {
      "name": "Timor-Leste",
      "iso_alpha3": "TLS"
    },
    {
      "name": "Togo",
      "iso_alpha3": "TGO"
    },
    {
      "name": "Tokelau",
      "iso_alpha3": "TKL"
    },
    {
      "name": "Tonga",
      "iso_alpha3": "TON"
    },
    {
      "name": "Trinidad and Tobago",
      "iso_alpha3": "TTO",
      "active": true
    },
    {
      "name": "Tunisia",
      "iso_alpha3": "TUN"
    },
    {
      "name": "Turkey",
      "iso_alpha3": "TUR"
    },
    {
      "name": "Turkmenistan",
      "iso_alpha3": "TKM"
    },
    {
      "name": "Turks and Caicos Islands",
      "iso_alpha3": "TCA"
    },
    {
      "name": "Tuvalu",
      "iso_alpha3": "TUV"
    },
    {
      "name": "Uganda",
      "iso_alpha3": "UGA"
    },
    {
      "name": "Ukraine",
      "iso_alpha3": "UKR"
    },
    {
      "name": "United Arab Emirates",
      "iso_alpha3": "ARE"
    },
    {
      "name": "United Kingdom of Great Britain and Northern Ireland",
      "iso_alpha3": "GBR"
    },
    {
      "name": "United States of America",
      "iso_alpha3": "USA",
      "weight": 99,
      "active": true
    },
    {
      "name": "United States Minor Outlying Islands",
      "iso_alpha3": "UMI"
    },
    {
      "name": "Uruguay",
      "iso_alpha3": "URY",
      "active": true
    },
    {
      "name": "Uzbekistan",
      "iso_alpha3": "UZB"
    },
    {
      "name": "Vanuatu",
      "iso_alpha3": "VUT"
    },
    {
      "name": "Venezuela (Bolivarian Republic of)",
      "iso_alpha3": "VEN",
      "active": true
    },
    {
      "name": "Viet Nam",
      "iso_alpha3": "VNM"
    },
    {
      "name": "Virgin Islands (British)",
      "iso_alpha3": "VGB"
    },
    {
      "name": "Virgin Islands (U.S.)",
      "iso_alpha3": "VIR"
    },
    {
      "name": "Wallis and Futuna",
      "iso_alpha3": "WLF"
    },
    {
      "name": "Western Sahara",
      "iso_alpha3": "ESH"
    },
    {
      "name": "Yemen",
      "iso_alpha3": "YEM"
    },
    {
      "name": "Zambia",
      "iso_alpha3": "ZMB"
    },
    {
      "name": "Zimbabwe",
      "iso_alpha3": "ZWE"
    }
  ]
)
