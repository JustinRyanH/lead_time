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

headers = ["Deployment Sha", "Deployment Time", "Commit Sha", "Commit Time", "Author", "Time Till Deploy (Minutes)"]
CSV.open("./deployments.csv", 'w') do |csv|
  csv << headers
  total_deployments = deployments.raw.count
  current_deployment = 0
  deployments.raw[0..100].each do |deployment|
    puts "#{total_deployments - current_deployment} Deployments to go"
    deployment_time = deployment.time
    deployment_sha = deployment.sha
    deployments.get_commits(deployment.id)&.each do |commit|
      ttd = ((deployment_time - commit.time) * 24 * 60).to_i
      csv << [deployment_sha, deployment_time, commit.sha, commit.time, commit.author.email, ttd]
    end
    current_deployment += 1
  end
end
