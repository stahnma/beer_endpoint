#!/usr/bin/env ruby

require "rubygems"
require 'json'
require 'sinatra'
require 'open-uri'

SPREADSHEET_URL = 'https://docs.google.com/spreadsheets/d/1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY/export?format=tsv&id=1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY&gid=0'
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

def whats_on_tap(session)
  rows = open(SPREADSHEET_URL).each_line

  rows.drop(1).map do |row|
    values = row.split("\t").map(&:strip)

    Hash[BEER_FIELDS.zip(values)]
  end
end
