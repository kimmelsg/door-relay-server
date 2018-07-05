require 'rack'
require 'json'
require 'yaml'
require 'sqlite3'

require './lib/relay'

CONFIG = YAML.load_file('config.yml')

DB = SQLite3::Database.new(CONFIG[:logging][:database])

if CONFIG[:debug]
  RELAY = Class.new do
    def self.on(relay)
      false
    end

    def self.off(relay)
      false
    end
  end
else
  begin
    RELAY = Relay.new(CONFIG[:relay][:file])
  rescue RubySerial::Error
    puts '!! Unable to establish connection to relay...'
    exit(1)
  end
end
