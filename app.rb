#!/usr/bin/env ruby

require "rubygems"
require 'json'
require 'sinatra'
require 'open-uri'

SPREADSHEET_URL = 'https://docs.google.com/spreadsheets/d/1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY/export?format=tsv&id=1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY&gid=2047460198'
#SPREADSHEET_URL = 'https://docs.google.com/spreadsheets/d/1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY/export?format=tsv&id=1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY&gid=0'
BEER_FIELDS = [:tap, :brewery, :beer_name, :style, :abv, :ibu, :link, :tap_date]

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

def validate(input,default)
  if input.nil? or input.empty?
    default
  else
    input
  end
end

def whats_on_tap(session)
  rows = open(SPREADSHEET_URL).each_line

  rows.drop(1).map do |row|
    values = row.split("\t").map(&:strip)
    v = []
    # :tap, :brewery, :beer_name, :style, :abv, :ibu, :link, :tap_date
    v[0] = validate(values[0],"Tap 16")         # green dragon secret tap
    v[1] = validate(values[1],"Empty")
    v[2] = validate(values[2],"Sadness")
    v[3] = validate(values[3],"Bud Lite Ultra Lime")
    v[4] = validate(values[4],"n/a")          # ABV
    v[4].gsub!('%','')     # strip % to avoid confusing erb
    v[5] = validate(values[5],"n/a")          # IBU
    v[6] = validate(values[6],"http://untappd.com/")
    v[7] = validate(values[7],"1/12/1997")
    Hash[BEER_FIELDS.zip(v)]
  end
end
