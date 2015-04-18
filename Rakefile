require 'erb'
require 'csv'
require 'erb'
require 'json'
require 'nokogiri'
require 'pp'

require_relative "lib/utils"
require_relative "lib/cs"
require_relative "lib/template"

namespace :clear do

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