# frozen_string_literal: true
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'oauth2'
gem 'json'

group :development, :test do
	gem 'minitest'
  gem 'minitest-reporters'
  gem 'mocha'
	gem 'vcr'
	gem 'rake'
	gem 'dotenv'
	gem 'webmock'
end
