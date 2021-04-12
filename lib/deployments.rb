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

