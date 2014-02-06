require 'cocoapods'
require 'octokit'
require 'pry'

class Pod::Specification
  class << self
    def github_client
      @client ||= Octokit::Client.new(oauth_token: ENV['GITHUB_TOKEN'])
    end
  end

  def git_repo
    source[:git]
  end

  def github?
    git_repo && git_repo.start_with?('https://github.com')
  end

  def github_repo_name
    match_data = git_repo.match("https://github.com/(.+?)/(.+?).git")
    "#{match_data[1]}/#{match_data[2]}"
  end

  def github_repo
    @repo ||= self.class.github_client.repo(github_repo_name)
  end
end

specs = Pod::SourcesManager.all_sets.map(&:specification)
# specs = specs.first(5) # For testing

github_specs = specs.select do |spec|
  puts "Checking #{spec.name}"
  # sleep 1 # Be nice to GitHub
  begin
    spec.github? && !!spec.github_repo
  rescue Octokit::NotFound
    false
  end
end
github_specs = github_specs.sort_by { |spec| - spec.github_repo.stargazers_count }


File.open("cocoapods_rank.md", "w+") do |f|
  f.puts "# CocoaPods Rank"
  f.puts "\n\n"
  f.puts "Sorted by stargazers count of GitHub repo"
  f.puts "\n\n"

  github_specs.each do |spec|
    puts "#{spec.name}: #{spec.github_repo.stargazers_count}"
    f.puts "* #{spec.github_repo.stargazers_count} [#{spec.name}](#{spec.homepage})"
  end

  f.puts "\n\n"
  f.puts "Generated by [@luvtechno](https://github.com/luvtechno/)"
end

# stargazers_count
# forks_count

# binding.pry
