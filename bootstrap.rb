require 'rack'
require 'json'
require 'yaml'
require 'sqlite3'

require './lib/application'

CONFIG = YAML.load_file('config.yml')
APPLICATION = Application.new(CONFIG)
