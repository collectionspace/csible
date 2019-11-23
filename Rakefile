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
require_relative 'lib/csible/csv'
require_relative 'lib/csible/http'
require_relative 'lib/csible/utils'

# global config, client and logger
CONFIG = Csible.get_config('api.json')
CLIENT = Csible.get_client(CONFIG[:services])
LOG    = Logger.new(STDOUT)

# cli tasks
require_relative 'lib/cli/cs'
require_relative 'lib/cli/template/cs'

task default: 'cs:config'

namespace :clear do
  # rake clear:all
  desc 'Remove generated files from imports, tmp and transforms'
  task :all do |_t|
    Rake::Task['clear:imports'].invoke
    Rake::Task['clear:tmp'].invoke
  end

  desc 'Remove XML files from imports'
  task :imports do |_t|
    Dir['imports/*.xml'].each do |file|
      Csible.clear_file file
    end
  end

  desc 'Remove XML files from tmp'
  task :tmp do |_t|
    Dir['tmp/*.xml'].each do |file|
      Csible.clear_file file
    end
  end
end
