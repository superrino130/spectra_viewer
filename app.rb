require 'sinatra'
require 'sinatra/reloader'
require 'net/http'

require 'erb'
require 'date'
require_relative 'chart'
require_relative 'readjson'
require_relative 'readdatasets'
require_relative 'public/jpostid'

@@datasets = {}

get '/jpost/:pxd/:peaklistfile' do
  if params['pxd'] && params['peaklistfile']
    scanid = Jpostdb::Table[params['pxd']][params['peaklistfile']]
    return 'bad request 44' if scanid.nil?
    @url = "https://repository.jpostdb.org/proxi/spectra?usi=mzspec:#{params['pxd']}:#{params['peaklistfile']}:scan:#{scanid}&resultType=full"
    @data = ReadJson.read_uri(@url)
    @title = @@datasets[params['pxd']]['title']
    @jpd = @@datasets[params['pxd']]['jpd']
    erb :scatterg
  else
    'bad request 23'
  end
end

get '/jpost/:pxd' do
  if params['pxd'] && @@datasets.include?(params['pxd'])
    @data = @@datasets[params['pxd']]
    @pxd = params['pxd']
    erb :details
  else
    'bad request 33'
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