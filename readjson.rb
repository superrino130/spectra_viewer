require 'net/http'
require 'uri'

module ReadJson
  module_function

  def read_uri(url)
    uri = URI.parse(url)
    res = Net::HTTP.get(uri)
    # res = Net::HTTP.get_response(uri)
    # raise "Not Connected by Code #{res.code.to_i}." if res.code.to_i != 200
    return res
    
    json_data = JSON.parse(res)

    
    mzs = []
    its = []
    json_data[0]['mzs'].zip(json_data[0]['intensities']).each do |m, i|
      case m.to_f
      when 0...1500
        mzs << m.to_f
        its << i.to_f
      end
    end
    [mzs, its]
  end
end
