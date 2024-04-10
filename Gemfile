source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# This gem supports operating on xlsx files (Open XML format). While it is capable of properly parsing the entire OOXML structure
gem 'rubyXL'

# Use mysql as the database for Active Record
gem 'mysql2', '~> 0.5.5'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.3"

# A simple HTTP and REST client for Ruby, inspired by the Sinatra microframework style of specifying actions: get, put, post, delete.
gem 'rest-client'

# Ruby internationalization and localization (i18n) solution.
gem 'i18n'

# Makes http fun again! Ain't no party like a httparty, because a httparty don't stop.
gem 'httparty'

# Wicked PDF uses the shell utility wkhtmltopdf to serve a PDF file to a user from HTML.``
gem 'wicked_pdf'

# This gem installs a binary stub that tries to determine which wkhtmltopdf binary will work on your system, and point to the packaged binary that most closely matches.
gem 'wkhtmltopdf-binary'

# Cocoon makes it easier to handle nested forms.
gem 'cocoon'

# This library can read and write PNG files
gem 'chunky_png'

# Barcode
gem 'barby'

# ApexCharts.RB is a ruby charting library that's going to give your ruby app beautiful, interactive, and responsive charts powered by ApexCharts.JS
gem 'apexcharts'

# will_paginate is a pagination library that integrates with Ruby on Rails, Sinatra, Hanami::View, and Sequel.
gem 'will_paginate-bootstrap4'

# An easy way to keep your users' passwords secure.
gem 'bcrypt'

# Devise is a flexible authentication solution for Rails based on Warden
gem 'devise'

# Use Sass to process CSS
gem 'sassc-rails'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Nokogiri (鋸) is an HTML, XML, SAX, and Reader parser. Among Nokogiri's many features is the ability to search documents via XPath or CSS3 selectors.
gem 'nokogiri'

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'dotenv-rails'

  # debbugers
  gem 'pry'
  gem 'pry-byebug'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

gem "sidekiq", "~> 7.2"
