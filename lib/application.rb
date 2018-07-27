require 'json'

require './lib/logger'

#
# The main application which controls the relay controller
# based on the request from the HTTP server.
#
class Application
  def initialize(config)
    @config = config
    setup_relay
  end

  # @param [Integer] scan The scan ID from the api.
  # @param [String] command The command to send to the relay.
  # @param [Integer] relay The index of the relay.
  def request(scan:, command:, relay:)
    @params = {
      scan: scan,
      command: command,
      relay: relay
    }
    return invalid_request unless valid_request?
    return send_scan_command if command == 'scan'
    valid_request
  end

  private

  attr_reader :config, :relay, :params
  attr_writer :params

  def setup_relay
    if config[:debug]
      require './lib/mock_relay'
      @relay = Relay.new(config[:relay][:file])
    else
      production_relay
    end
  end

  def production_relay
    require './lib/relay'
    begin
      @relay = Relay.new(config[:relay][:file])
    rescue RubySerial::Error
      puts '!! Unable to establish connection to relay...'
      exit(1)
    end
  end

  def valid_request?
    return false unless (1..8).cover? params[:relay]
    return false unless %w[on off scan].include? params[:command]
    true
  end

  def invalid_request
    response = {
      success: false,
      message: 'Invalid Request'
    }
    log(response)
    ['400', { 'Content-Type:' => 'text/html' }, [response.to_json]]
  end

  def valid_request
    result = send_command
    response = {
      success: result.success?,
      message: result.message,
      payload: result.payload
    }
    log(response)
    ['200', { 'Content-Type:' => 'text/html' }, [response.to_json]]
  end

  def send_scan_command
    params[:command] = 'on'
    on_result = send_command
    params[:command] = 'off'
    off_result = send_command
    response = {
      success: on_result.success? && off_result.success?,
      message: `#{on_result.message} && #{off_result.message}`,
      payload: `#{on_result.payload} && #{off_result.payload}`
    }
    log(response)
    ['200', { 'Content-Type:' => 'text/html' }, [response.to_json]]
  end

  # @param [Hash] response The result of the request.
  def log(response)
    logger.log(params.merge(response: response.to_json))
  end

  def database
    @database ||= SQLite3::Database.new(config[:logging][:database])
  end

  def logger
    @logger ||= Logger.new(database: database)
  end

  def send_command
    relay.send params[:command], params[:relay]
  end
end
