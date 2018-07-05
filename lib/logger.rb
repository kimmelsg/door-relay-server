#
# Simply logs data to the SQLite3 database
#
class Logger
  def initialize(database:)
    @db = database
  end

  # @params [Integer] scan The id of the scan from the api.
  # @params [Integer] relay The relay index.
  # @params [String] command The command to send to the relay.
  # @response [String] response The response or result from the server.
  def log(scan:, relay:, command:, response:)
    db.execute(
      'INSERT INTO requests ( `scan`, `relay`, `command`, `response` ) VALUES ( ?, ?, ?, ? )',
      [scan, relay, command, response]
    )
  end

  private

  attr_reader :db
end
