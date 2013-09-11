#!/usr/bin/env ruby

require "rubygems"
require "google_drive"
require 'json'
require 'sinatra'

GOOGLE_DRIVE_USERNAME= ENV['GOOGLE_DRIVE_USERNAME'] || 'stahnma@puppetlabs.com'
GOOGLE_DRIVE_PASSWORD= ENV['GOOGLE_DRIVE_PASSWORD'] || nil
# https://docs.google.com/a/puppetlabs.com/spreadsheet/ccc?key=0AkXn6HayGVSrdEt1Y091QXppdXhLOGNYZVdmdEpoQXc
GOOGLE_BEER_SPREADSHEET_ID='0AkXn6HayGVSrdEt1Y091QXppdXhLOGNYZVdmdEpoQXc'

# GoogleDrive.login_with_oauth
begin
  session = GoogleDrive.login(GOOGLE_DRIVE_USERNAME, GOOGLE_DRIVE_PASSWORD)
rescue
  puts "Authenticaiton problem..."
  exit 1
end

set :port, 8334
set :bind, '0.0.0.0'
set :erb, :trim => '-'

get '/' do
  @kegerator = whats_on_tap(session)
  erb :index
end

get '/api/v1/beer' do
  content_type :json
  whats_on_tap(session).to_json
end

def whats_on_tap(session)
  ws = session.spreadsheet_by_key(GOOGLE_BEER_SPREADSHEET_ID).worksheets[0]
  beertap   = {}
  kegerator = []
  counter   = 0
  ws.rows.each do |row|
    if counter == 0
      counter = counter +1
      next
    end
    counter = counter +1
    beertap = {}
    beertap[:tap]       = row[0]
    beertap[:brewery]   = row[1]
    beertap[:beer_name] = row[2]
    beertap[:style]     = row[3]
    beertap[:abv]       = row[4]
    beertap[:link]      = row[5]
    beertap[:tap_date]  = row[6]
    kegerator << beertap
  end
  kegerator
end
