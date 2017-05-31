#!/usr/bin/env ruby

require "rubygems"
require 'json'
require 'open-uri'
require 'tilt/erb'
require 'sinatra'

# this is the second tab of the spreasheet, for testing changes to the input data
#SPREADSHEET_URL = 'https://docs.google.com/spreadsheets/d/1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY/export?format=tsv&id=1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY&gid=2047460198'

# this is the 'live' tap list
SPREADSHEET_URL = 'https://docs.google.com/spreadsheets/d/1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY/export?format=tsv&id=1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY&gid=0'
BEER_FIELDS =  [:tap, :brewery, :beer_name, :style, :abv, :ibu, :link, :tap_date, :vol]
DEFAULT_VALS = ["Tap 16", "Temporarily", "Offline", "n/a", "n/a",
                "n/a", "http://untappd.com", "1/12/1997", "empty"]

set :port, 8334
set :bind, '0.0.0.0'
set :erb, :trim => '-'
set :static, true
set :public_folder, Proc.new { File.join(File.dirname(__FILE__), 'public')  }

get '/' do
  @kegerator = whats_on_tap(session)
  erb :index
end

get '/api/v1/beer' do
  content_type :json
  whats_on_tap(session).to_json
end

def validate(default,input)
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
    DEFAULT_VALS.zip(values).each do |default,value|
      v << validate(default,value)
    end
    v[4].gsub!('%','')     # strip % to avoid confusing erb
    Hash[BEER_FIELDS.zip(v)]
  end
end
