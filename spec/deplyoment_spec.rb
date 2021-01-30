require 'spec_helper'
require 'deployments'
require 'commit_collector'
require 'date'


describe Deployments::Deployments do
  it 'creates deployments per day' do
    collector = instance_double("CommitCollector")
    deployment_a = Deployments::Deployment::new(10, "aaaaaaa", "justin", DateTime.new(2020, 02, 10, 10, 30), nil)
    deployment_b = Deployments::Deployment::new(11, "bbbbbbb", "justin", DateTime.new(2020, 02, 10, 9, 30), nil)
    deployment_c = Deployments::Deployment::new(12, "ccccccc", "justin", DateTime.new(2020, 02, 9, 9, 30), nil)

    deployments = Deployments::Deployments.new([deployment_a, deployment_b, deployment_c], commit_collector: collector)
    expect(deployments.by_day.keys.size).to eq 2
    expect(deployments.by_day[Date.new(2020, 02, 10)]).to include deployment_a
    expect(deployments.by_day[Date.new(2020, 02, 10)]).to include deployment_b
    expect(deployments.by_day[Date.new(2020, 02, 9)]).to include deployment_c
  end

  it 'allows accessing deployments by id' do
    collector = instance_double("CommitCollector")
    deployment_a = Deployments::Deployment::new(10, "aaaaaaa", "justin", DateTime.new(2020, 02, 10, 10, 30), nil)
    deployment_b = Deployments::Deployment::new(11, "bbbbbbb", "justin", DateTime.new(2020, 02, 10, 9, 30), nil)
    deployment_c = Deployments::Deployment::new(12, "ccccccc", "justin", DateTime.new(2020, 02, 9, 9, 30), nil)

    deployments = Deployments::Deployments.new([deployment_a, deployment_b, deployment_c], commit_collector: collector )
    expect(deployments[10].previous_deployment).to eq 'bbbbbbb'
    expect(deployments[11].previous_deployment).to eq 'ccccccc'
  end

  it 'shows which commits are between commits' do
    collector = instance_double("CommitCollector")
    deployment_a = Deployments::Deployment::new(10, "aaaaaaa", "justin", DateTime.new(2020, 02, 10, 10, 30), 'bbbbbbb')
    example_commit = Commit.new(sha: 'aaabbbb', time: DateTime.new(2020, 02, 10, 10, 29), name: 'ruby', email: 'ruby@example.com')
    allow(collector).to receive(:gather_commits).with(deployment_a).and_return([example_commit])

    deployments = Deployments::Deployments.new([deployment_a], commit_collector: collector )

    expect(deployments.get_commits(10)).to include(example_commit)
  end
end
