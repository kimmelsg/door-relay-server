require './relay'

relay = Relay.new('/dev/ttyUSB0')

puts relay.on(1)
puts relay.off(1)
puts relay.status(1)
