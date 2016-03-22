module Csible

  def self.clear_file(file, log = Logger.new(STDOUT))
    File.unlink file
    log.info "Deleted: #{file}"
  end

  def self.get_client(config)
    CollectionSpace::Client.new(CollectionSpace::Configuration.new(config))
  end

  def self.get_config(path)
    JSON.parse( IO.read(path), symbolize_names: true )
  end

  def self.get_element_values(file, element)
    response = Nokogiri::XML.parse(File.open(file))
    values   = response.css(element).map(&:text)
    values
  end  

  def self.get_template(template_file)
    ERB.new( File.read(template_file) )
  end

  def self.write_csv(filename, data, log = Logger.new(STDOUT))
    ::CSV.open(filename, 'w') do |csv|
      csv << data.first.keys
      data.each { |row| csv << row.values }
    end
    log.info "Created #{filename}"
  end

  def self.write_file(filename, data, log = Logger.new(STDOUT))
    File.open(filename, 'w') {|f| f.write(data) }
    log.info "Created #{filename}"
  end

end
