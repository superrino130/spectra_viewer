require 'net/http'
require 'uri'
require 'json'

module ReadJson
  module_function

  def read_uri(url)
    uri = URI.parse(url)
    res = Net::HTTP.get(uri)
    
    json_data = JSON.parse(res.chomp)
    
    mzs_its = []
    json_data[0]['mzs'].zip(json_data[0]['intensities']).each do |m, i|
      case m.to_f
      when 0...1500
        mzs_its << [m.to_f, i.to_f]
      end
    end
    mzs_its
  end
end
