class Author < Struct.new(:name, :email)
end

class Commit < Struct.new(:sha, :time, :author)
  def initialize(sha:, time:, name:, email:)
    author = Author.new(name, email)
    super(sha, time, author)
  end
end

class CommitCollector
  def initialize(api_token: GITHUB_TOKEN)
    client = Octokit::Client.new(:access_token => api_token)
    user   = client.user
    user.login
    @client = client
  end

  def gather_commits(deployment)
    @client.compare(GITHUB_REPO, deployment.previous_deployment, deployment.sha).commits.map do |cm|
      if cm.commit.message.include?("Merge pull request ")
        sha = cm.sha
        author = cm.commit.author
        date = author.date.to_datetime
        date.new_offset("+0000")

        Commit.new(sha: sha, time: date, name: author.name, email: author.email)
      end
    end.compact
  end
end
