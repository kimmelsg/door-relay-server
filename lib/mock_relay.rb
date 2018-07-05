require './lib/result'

#
# This class mocks Relay.rb for times
# when there is no relay connected.
#
class Relay
  def initialize(_path); end

  def on(_relay)
    Result.failure(message: 'Mocked failure')
  end

  def off(_relay)
    Result.success(message: 'Mocked Success')
  end

  def status(_relay)
    Result.success(message: 'Mocked Success w/ payload', payload: ['1'])
  end
end
