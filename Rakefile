require 'active_support'
require 'active_support/core_ext'
require 'base64'
require 'erb'
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

require_relative "lib/utils"
require_relative "lib/cs"
require_relative "lib/template"

log_file = "response.log"
FileUtils.touch(log_file)
@log = Logger.new File.open(log_file, "a")

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