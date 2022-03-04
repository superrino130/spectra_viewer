require 'net/http'
require 'json'

module ReadDatasets
  module_function

  def read_jpost
    url = 'https://repository.jpostdb.org/proxi/datasets?resultType=full'

    uri = URI.parse(url)
    res = Net::HTTP.get_response(uri)
    jsons = JSON.parse(res.body)
    info = {}
    jsons.each do |json|
      json.each do |k, v|
        case k
        when 'accession'
          v.each do |ve|
            if ve['name'] == 'ProteomeXchange accession number'
              @pxd = ve['value']
              info[@pxd] = {}
            end
          end
        when 'title'
          info[@pxd]['title'] = v
        when 'description'
          info[@pxd]['description'] = v
        when 'contacts'
          v.each do |ve|
            s = ve.to_s.match(/contact name\"\,\s*\"value\"=>\"\w*\s*\w*\"}/)
            if s
              info[@pxd]['contact name'] ||= []
              info[@pxd]['contact name'] << s[0].split('>')[1].gsub(/\"/, '').sub('}', '')
            end
          end
        when 'keywords'
          info[@pxd]['keywords'] ||= []
          v.each do |ve|
            info[@pxd]['keywords'] << ve['value']
          end
        when 'species'
          info[@pxd]['species'] ||= []
          v.each do |ve|
            info[@pxd]['species'] << ve['value']
          end
        when 'datasetFiles'
          info[@pxd]['Peak list file URI'] ||= []
          v.each do |ve|
            info[@pxd]['Peak list file URI'] << ve['value'].split('/')[-1]
          end
        end
      end
    end
    info
  end

  def read_massive
    url = 'http://massive.ucsd.edu/ProteoSAFe/proxi/v0.1/datasets?resultType=full'

  end
end
