#!/usr/bin/env ruby

require 'rubygems'

require 'github_api'

GITHUB_API_URL = "https://api.github.com"

module_names = ARGV[0]

if ARGV[0].nil? || ARGV[0].empty?
  puts "Comma separated list of module names must be provided (without the puppet- prefix)"
  exit 1
end

if ENV['GITHUB_OAUTH_TOKEN'].nil? || ENV['GITHUB_OAUTH_TOKEN'].empty?
  puts "Env variable GITHUB_OAUTH_TOKEN must be provided"
  exit 1
end

if ENV['GITHUB_USERNAME'].nil? || ENV['GITHUB_USERNAME'].empty?
  puts "Env variable GITHUB_USERNAME must be provided"
  exit 1
end

module_names.split(',').each do |module_name|
  puts "Creating module puppet-#{module_name}"

  github = Github.new :oauth_token => "#{ENV['GITHUB_OAUTH_TOKEN']}"
  github.repos.create "name" => "puppet-#{module_name}",
      "private" => false,
      "has_issues" => true,
      "has_wiki"=> true,
      "has_downloads" => true
  puts "Created remote Github repository puppet-#{module_name}"

  `git clone --depth 1 git@github.com:#{ENV['GITHUB_USERNAME']}/puppet-template.git puppet-#{module_name}`
  Dir.chdir("puppet-#{module_name}") {
    `rm -rf .git`
    `git init`
    `mkdir spec/classes`
    `touch spec/classes/#{module_name}_spec.rb`
    `rm spec/fixtures/Puppetfile`
    `git add .`
    `git commit -m "Initial repository layout"`
    `git remote add origin git@github.com:#{ENV['GITHUB_USERNAME']}/puppet-#{module_name}.git`
    `git push origin master`
  }
end
