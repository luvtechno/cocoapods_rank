require 'cocoapods'
require 'octokit'
require 'pry'

class Pod::Specification
  def git_repo
    source[:git]
  end

  def github?
    git_repo && git_repo.start_with?('https://github.com')
  end

  def github_repo
    match_data = git_repo.match("https://github.com/(.+?)/(.+?).git")
    "#{match_data[1]}/#{match_data[2]}"
  end


end

specs = Pod::SourcesManager.all_sets.map(&:specification)
github_specs = specs.select(&:github?)

binding.pry

