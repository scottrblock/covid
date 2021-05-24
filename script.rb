require 'uri'
require 'net/http'
require 'csv'
require 'json'

STATES = ["AK", "AL", "AR", "AS", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "GU", 
    "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", 
    "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN", "TX", 
    "UT", "VA", "VI", "VT", "WA", "WI", "WV", "WY"].freeze

PROPERTIES = ["name", "state", "location_type", "phone_number", "full_address", "city", "county", "zip_code", "website", "vts_url"]


CSV.open("output.csv", "w") do |csv| #open new file for write
  STATES.each_with_index do |state, i|
    uri = URI("https://api.vaccinatethestates.com/v0/#{state}.geojson")
    res =  Net::HTTP.get_response(uri)
    JSON.parse(res.body)['features'].each_with_index do |feature, j|      
      row = {}
      row['id'] = feature['id']
      PROPERTIES.each do |property|
        row[property] = feature['properties'][property]
      end

      raise "unknown geometry" if feature['geometry']['type'] != 'Point' 
      row['lng'] = feature['geometry']['coordinates'][0]
      row['lat'] = feature['geometry']['coordinates'][1]

      if(i == 0 && j == 0)
        csv << row.keys  
      end

      csv << row.values
    end
  end
end