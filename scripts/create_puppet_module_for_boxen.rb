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

  `git clone --depth 1 git://github.com/boxen/puppet-template.git puppet-#{module_name}`
  Dir.chdir("puppet-#{module_name}") {
    `rm -rf .git`

    `sed '1,35d' README.md`
    `sed -i '' '3,8d' README.md`
    `sed -i '' '16d' README.md`
    `sed -i '' 's/template/#{module_name}/g' README.md`

    `sed -i '' '1d' manifests/init.pp`
    `sed -i '' 's/template/#{module_name}/g' manifests/init.pp`

    `mv spec/classes/template_spec.rb spec/classes/#{module_name}_spec.rb`
    `sed -i '' '2,4d' spec/classes/#{module_name}_spec.rb`
    `sed -i '' '/require/G' spec/classes/#{module_name}_spec.rb`
    `sed -i '' 's/template/#{module_name}/g' spec/classes/#{module_name}_spec.rb`

    `git init`

    `git add .`
    `git commit -m "Initial repository layout"`

    `git remote add origin git@github.com:#{ENV['GITHUB_USERNAME']}/puppet-#{module_name}.git`
    `git push origin master`
  }
end
