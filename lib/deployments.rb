module Deployments
  class Deployment < Struct.new(:id, :sha, :user, :time, :previous_deployment)
    def self.from_json(json_deployment)
      time = DateTime.parse(json_deployment["timestamp"])
      Deployment.new(json_deployment["id"], json_deployment["revision"], json_deployment["user"], time, nil)
    end

    def date
      cloned_time = time.clone
      cloned_time.new_offset("+0000")
      cloned_time.to_date
    end
  end

  class Deployments
    def initialize(deployments, commit_collector:)
      @deployments = deployments.sort_by(&:time)
      @commit_collector = commit_collector
    end

    def [](deployment_id)
      setup_data
      deployments_by_id[deployment_id]
    end

    def by_day
      setup_data
      @deployments_by_day ||= begin
        @deployments.each_with_object(Hash.new([])) do |item, hash|
          date       = item.date
          hash[date] = hash[date] + [item]
        end
      end
    end

    def raw
      setup_data
      @deployments.reverse
    end

    def get_commits(deployment_id)
      deployment = deployments_by_id[deployment_id]
      return if deployment.previous_deployment.nil?
      return @commit_collector.gather_commits(deployment)
    end

    private

    def setup_data
      set_previous_deployments
    end

    def deployments_by_id
      @deployments_by_id ||= @deployments.each_with_object({}) { |item, hash| hash[item.id] = item }
    end

    def set_previous_deployments
      @deployments.each_with_index do |deployment, index|
        next unless index > 0
        previous_deployment            = @deployments[index - 1]
        deployment.previous_deployment = previous_deployment.sha
      end
    end
  end
end

