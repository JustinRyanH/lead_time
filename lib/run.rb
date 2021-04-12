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

require 'csv'
require 'date'
require 'json'
require 'net/http'

require 'octokit'

require_relative '../keys'
require_relative './new_relic'
require_relative './deployments'
require_relative './commit_collector'

collector = CommitCollector.new()
deployments = NewRelic::load_deployments(application_id: APP_ID, commit_collector: collector, api_key: NEW_RELIC_API_KEY)

headers = ["Deployment Date", "Deployment Sha", "Deployment Time", "Commit Sha", "Commit Time", "Author", "Time Till Deploy (Minutes)"]
CSV.open("./deployments.csv", 'w') do |csv|
  csv << headers
  total_deployments = deployments.raw.count
  current_deployment = 0
  deployments.raw[0..10].each do |deployment|
    puts "#{total_deployments - current_deployment} Deployments to go"
    deployment_time = deployment.time
    deployment_date = deployment.date
    deployment_sha = deployment.sha
    deployments.get_commits(deployment.id)&.each do |commit|
      ttd = ((deployment_time - commit.time) * 24 * 60).to_i
      csv << [deployment_date, deployment_sha, deployment_time, commit.sha, commit.time, commit.author.email, ttd]
    end
    current_deployment += 1
  end
end
