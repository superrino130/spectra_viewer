require 'sinatra'
require 'sinatra/reloader'
require 'net/http'
# require 'chartkick'

require 'erb'
require 'date'
require_relative 'chart'
require_relative 'readjson'
require_relative 'readdatasets'
require_relative 'public/jpostid'

@@datasets = {}

get '/jpost2' do
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

get '/jpost/:pxd/:peaklistfile' do
  if params['pxd'] && params['peaklistfile']
    scanid = Jpostdb::Table[params['pxd']][params['peaklistfile']]
    return 'bad request 44' if scanid.nil?
    url = "https://repository.jpostdb.org/proxi/spectra?usi=mzspec:#{params['pxd']}:#{params['peaklistfile']}:scan:#{scanid}&resultType=full"
    mzs, its = ReadJson.read_uri(url)
  else
    'bad request 48'
  end
end

get '/jpost/:pxd' do
  if params['pxd'] && @@datasets.include?(params['pxd'])
    @data = @@datasets[params['pxd']]
    @pxd = params['pxd']
    erb :details
  else
    'bad request 58'
  end
end

get '/jpost' do
  @@datasets.merge!(ReadDatasets.read_jpost)
  @data = @@datasets
  erb :jpost
end

get '/' do
  @@datasets.clear

  erb :index
end

error 400..510 do
  'Protein deficiency'
end