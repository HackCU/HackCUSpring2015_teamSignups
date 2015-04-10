require 'github_api'
require 'octokit'

GITHUB = Github.new basic_auth: "ianks:#{ENV['GITHUB_PW']}"
CLIENT = Octokit::Client.new login: 'ianks', password: ENV['GITHUB_PW']

# Teams for the Hackathon!
class Team
  def initialize(name:, members:)
    @name, @members = name, members
  end

  def self.create(*args)
    new(*args).tap do |team|
      team.create_team
      team.add_members
      team.add_repo
    end
  end

  def create_team
    @team = CLIENT.create_team(
      'HackCU',
      name: @name,
      permissions: 'admin',
      repo_names: []
    )
  end

  def add_members
    @members.each do |member|
      begin
        CLIENT.add_team_membership @team.id, member
      rescue => e
        STDERR.puts "Could not add member #{member} to #{@name}"
        STDERR.puts e
      end
    end
  end

  def add_repo
    begin
      CLIENT.create_repo @name, organization: 'HackCU', team_id: @team.id
    rescue => e
      STDERR.puts "Could not create repo for #{@name}"
      STDERR.puts e
    end
  end
end
