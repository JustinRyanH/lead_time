require 'json'
require 'date'
require 'net/http'

require_relative './keys.rb'
require_relative './new_relic.rb'
require_relative './deployments'

deployments = NewRelic::load_deployments(application_id: APP_ID, api_key: NEW_RELIC_API_KEY)

deployments.by_day.keys.each do |date|
  puts deployments.by_day[date].size
end
