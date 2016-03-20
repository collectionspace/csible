require 'active_support'
require 'active_support/core_ext'
require 'awesome_print'
require 'base64'
require 'cgi'
require 'collectionspace/client'
require 'csv'
require 'erb'
require 'fileutils'
require 'json'
require 'logger'
require 'nokogiri'
require 'pp'
require 'redis'
require 'set'
require 'uri'

# support libs
require_relative "lib/csible/csv"
require_relative "lib/csible/http"
require_relative "lib/csible/utils"

# cli tasks
require_relative "lib/cli/cs"
require_relative "lib/cli/template/cs"
require_relative "lib/cli/template/pp"

namespace :clear do

  # rake clear:all
  desc "Remove generated files from imports, tmp and transforms"
  task :all do |t|
    Rake::Task["clear:imports"].invoke
    Rake::Task["clear:tmp"].invoke
    Rake::Task["clear:transforms"].invoke
  end

  desc "Remove XML files from imports"
  task :imports do |t|
    Dir["imports/*.xml"].each do |file|
      Csible.clear_file file
    end
  end

  desc "Remove XML files from tmp"
  task :tmp do |t|
    Dir["tmp/*.xml"].each do |file|
      Csible.clear_file file
    end
  end

  desc "Remove CSV files from transforms"
  task :transforms do |t|
    Dir["transforms/*.csv"].each do |file|
      Csible.clear_file file
    end
  end
end
