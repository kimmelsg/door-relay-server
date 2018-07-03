require './relay'

relay = Relay.new('/dev/ttyUSB0')

puts relay.on(1)
