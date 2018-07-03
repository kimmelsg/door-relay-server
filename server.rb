require 'rack'
require 'json'
require 'pry-byebug'

require './relay'

relay = Relay.new('/dev/ttyUSB0')

def valid_request?(params)
  return false unless (1..8).cover? params['relay'].to_i
  return false unless %w[on off].include? params['status']
  true
end

app = proc do |env|
  request = Rack::Request.new(env)
  params = request.params
  unless valid_request?(params)
    next ['400', { 'Content-Type' => 'text/html' }, ['Invalid Request']]
  end
  result = relay.send params['status'], params['relay'].to_i
  ['200', { 'Content-Type' => 'text/html' }, [result]]
end

Rack::Handler::WEBrick.run app
