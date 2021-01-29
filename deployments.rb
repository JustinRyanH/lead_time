module Deployments
  class Deployment < Struct.new(:id, :revision, :user, :time, :previous_deployment)
    def self.from_json(json_deployment)
      time = DateTime.parse(json_deployment["timestamp"])
      Deployment.new(json_deployment["id"], json_deployment["revision"], json_deployment["user"], time, nil)
    end
  end

  class Deployments
    def initialize(deployments)
      @deployments = deployments
    end

    def by_day
      @deployments_by_day ||= begin
        @deployments.each_with_object(Hash.new([])) do |item, hash|
          date       = item.time.to_date
          hash[date] = hash[date] + [item]
        end
      end
    end
  end
end

