require 'sinatra'
require 'sinatra/reloader'
require 'net/http'
require 'chartkick'

require 'erb'
require 'date'
require_relative 'chart'
require_relative 'readjson'

get '/jpost' do
  mzs, its = ReadJson.read_uri
  column = [{'string' => 'm/z'},{'number' => 'intensty'}]
  data = {}
  0.upto(1500) do |x|
    data[x] = 0
  end
  itsmax = its.max
  mzs.zip(its).each do |x, y|
    data[x] = (y / itsmax.to_f * 100).round(3) if x <= 1500
  end
  # options = [{'width' => 800},{'height' => 600}]
  options = [{'width' => 4800},{'height' => 600}]
  name = 'bar_chart'
  row = []
  data.sort_by{ _1 }.each do |k, v|
    row << {k => v}
  end
  
  pc = BarChart.new(column,row,options,name)
  @header = pc.header_script
  @body = pc.body_script   
  
  erb :jpost
end

get '/' do
  erb :index
end