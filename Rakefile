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

require_relative "lib/client.rb"
require_relative "lib/utils"
require_relative "lib/cs"
require_relative "lib/template"

namespace :clear do

  desc "Remove XML files from imports and tmp"
  task :all do |t|
    Rake::Task["clear:imports"].invoke
    Rake::Task["clear:tmp"].invoke
  end

  desc "Remove XML files from imports"
  task :imports do |t|
    Dir["imports/*.xml"].each do |file|
      clear_file file
    end
  end

  desc "Remove XML files from tmp"
  task :tmp do |t|
    Dir["tmp/*.xml"].each do |file|
      clear_file file
    end
  end
end
