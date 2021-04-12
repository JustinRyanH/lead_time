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
