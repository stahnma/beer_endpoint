#!/usr/bin/env ruby

require "rubygems"
require 'json'
require 'open-uri'
require 'tilt/erb'
require 'sinatra'

# this is the second tab of the spreasheet, for testing changes to the input data
# TAPS_URL = 'https://docs.google.com/spreadsheets/d/1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY/export?format=tsv&gid=1'

# this is the 'live' tap list
TAPS_URL = 'https://docs.google.com/spreadsheets/d/1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY/export?format=tsv&gid=0'
ON_DECK_URL = 'https://docs.google.com/spreadsheets/d/1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY/export?format=tsv&gid=382420153'
BEER_FIELDS =  [:tap, :brewery, :beer_name, :style, :abv, :ibu, :link, :tap_date, :vol, :delivery_date, :origin]
DEFAULT_VALS = ["Tap 16", "Temporarily", "Offline", "n/a", "n/a",
                "n/a", "empty", "1/12/1997", "empty", "1/12/1997", "n/a"]

set :port, 8334
set :bind, '0.0.0.0'
set :erb, :trim => '-'
set :static, true
set :public_folder, Proc.new { File.join(File.dirname(__FILE__), 'public')  }

get '/' do
  @kegerator = whats_on_tap(session)

  on_deck = whats_on_deck(session).sort_by do |keg|
    month, day, year = keg[:delivery_date].split('/')
    [year, month, day]
  end.each_with_object({:ipa => [], :cider => [], :other => [], :kombucha => []}) do |keg, styles|
    case keg[:style]
    when /ipa/i
      styles[:ipa] << keg
    when /cider/i
      styles[:cider] << keg
    when /kombucha/i
      styles[:kombucha] << keg
    else
      styles[:other] << keg
    end
  end

  @kegerator[0][:on_deck] = on_deck[:cider].first
  @kegerator[1][:on_deck] = on_deck[:ipa].first
  @kegerator[2][:on_deck] = on_deck[:other].first
  @kegerator[3][:on_deck] = on_deck[:kombucha].first

  erb :index
end

get '/api/v1/beer' do
  content_type :json
  whats_on_tap(session).to_json
end

get '/api/v1/ondeck' do
  content_type :json
  whats_on_deck(session).to_json
end

def validate(default,input)
  if input.nil? or input.empty?
    default
  else
    input
  end
end

def parse_sheet(session,url)
  rows = open(url).each_line

  rows.drop(1).map do |row|
    row.force_encoding('UTF-8')
    values = row.split("\t").map(&:strip)
    v = []
    # :tap, :brewery, :beer_name, :style, :abv, :ibu, :link, :tap_date, :vol, :delivery_date, :origin
    DEFAULT_VALS.zip(values).each do |default,value|
      v << validate(default,value)
    end
    v[4].gsub!('%','')     # strip % to avoid confusing erb
    Hash[BEER_FIELDS.zip(v)]
  end
end

def whats_on_tap(session)
  parse_sheet(session,TAPS_URL)
end

def whats_on_deck(session)
  parse_sheet(session,ON_DECK_URL)
end
