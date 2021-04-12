# Copyright (c) 2021 Mavenlink, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


require_relative './deployments.rb'

module NewRelic
  def self.load_deployments(application_id: , api_key:, commit_collector:)
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
      Deployments::Deployments.new(deployments, commit_collector: commit_collector)
    else
      raise Exception.new("Unsuccessful Request: \n#{res.body}")
    end
  end

end
