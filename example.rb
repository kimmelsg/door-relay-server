require 'relay'

relay = Relay.new(device: '/dev/ttyUSB0')

puts relay.on(1)