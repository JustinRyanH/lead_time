require_relative './deployments.rb'

module NewRelic
  def self.load_deployments(application_id: , api_key:)
    app_id = application_id
    uri = URI("https://api.newrelic.com/v2/applications/#{app_id}/deployments.json")
    req = Net::HTTP::Get.new(uri)
    req['X-Api-Key'] = api_key
    req['Content-Type'] = 'application/json'

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true

    res = http.request(req)
    case res
    when Net::HTTPSuccess then
      out = JSON.parse(res.body)
      deployments = out['deployments']
        .filter { |deployment| deployment["links"]["application"] == app_id.to_i  }
        .map { |d| Deployments::Deployment.from_json(d) }
      Deployments::Deployments.new(deployments)
    else
      raise Exception.new("Unsuccessful Request: \n#{res.body}")
    end
  end

end
