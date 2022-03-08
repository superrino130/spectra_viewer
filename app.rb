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

get '/jpost/:pxd/:peaklistfile/:scanid' do
  if params['pxd'] && params['peaklistfile'] && params['scanid']
    scanid = params['scanid']
    return 'bad request 17' if scanid.nil?
    @url = "https://repository.jpostdb.org/proxi/spectra?usi=mzspec:#{params['pxd']}:#{params['peaklistfile']}:scan:#{scanid}&resultType=full"
    @data = ReadJson.read_uri(@url)
    @title = @@datasets[params['pxd']]['title']
    @jpd = @@datasets[params['pxd']]['jpd']
    if ReadJson.check_uri("https://repository.jpostdb.org/proxi/spectra?usi=mzspec:#{params['pxd']}:#{params['peaklistfile']}:scan:#{scanid.to_i.next}&resultType=full")
      @nextdata = "/jpost/#{params['pxd']}/#{params['peaklistfile']}/#{scanid.to_i.next}"
    else
      @nextdata = nil
    end
    if ReadJson.check_uri("https://repository.jpostdb.org/proxi/spectra?usi=mzspec:#{params['pxd']}:#{params['peaklistfile']}:scan:#{scanid.to_i.pred}&resultType=full")
      @preddata = "/jpost/#{params['pxd']}/#{params['peaklistfile']}/#{scanid.to_i.pred}"
    else
      @preddata = nil
    end
    @returnurl = "/jpost/#{params['pxd']}"
    erb :scatterg
  else
    'bad request 24'
  end
end

get '/jpost/:pxd/:peaklistfile' do
  if params['pxd'] && params['peaklistfile']
    scanid = Jpostdb::Table[params['pxd']][params['peaklistfile']]
    return 'bad request 31' if scanid.nil?
    @url = "https://repository.jpostdb.org/proxi/spectra?usi=mzspec:#{params['pxd']}:#{params['peaklistfile']}:scan:#{scanid}&resultType=full"
    @data = ReadJson.read_uri(@url)
    @title = @@datasets[params['pxd']]['title']
    @jpd = @@datasets[params['pxd']]['jpd']
    if ReadJson.check_uri("https://repository.jpostdb.org/proxi/spectra?usi=mzspec:#{params['pxd']}:#{params['peaklistfile']}:scan:#{scanid.to_i.next}&resultType=full")
      @nextdata = "/jpost/#{params['pxd']}/#{params['peaklistfile']}/#{scanid.to_i.next}"
    else
      @nextdata = nil
    end
    if ReadJson.check_uri("https://repository.jpostdb.org/proxi/spectra?usi=mzspec:#{params['pxd']}:#{params['peaklistfile']}:scan:#{scanid.to_i.pred}&resultType=full")
      @preddata = "/jpost/#{params['pxd']}/#{params['peaklistfile']}/#{scanid.to_i.pred}"
    else
      @preddata = nil
    end
    @returnurl = "/jpost"
    erb :scatterg
  else
    'bad request 38'
  end
end

get '/jpost/:pxd' do
  if params['pxd'] && @@datasets.include?(params['pxd'])
    @data = @@datasets[params['pxd']]
    @pxd = params['pxd']
    erb :details
  else
    'bad request 48'
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