require 'rubyserial'

# -------------------------------------------------------- #
# This class is a interface between a NCD serial relay
# and ruby.
# -------------------------------------------------------- #
class Relay
  def initialize(device:, baudrate: 115_200, bytesize: 8)
    @serial = serial.Serial(device, baudrate, bytesize)
  end

  # turn on a relay
  def on(relay)
    lsb = relay - 1 & 255
    msb = relay >> 8
    command = wrap_in_api([254, 48, lsb, msb])
    process_control_command_return(send_command(command, 4))
  end

  def off(relay)
    lsb = relay - 1 & 255
    msb = relay >> 8
    command = wrap_in_api([254, 47, lsb, msb])
    process_control_command_return(send_command(command, 4))
  end

  private

  attr_reader :serial

  # verify data is setup for controller to process
  def wrap_in_api(data)
    bytes_in_packet = data.length
    data = data.unshift(bytes_in_packet)
    data = data.unshift(170)
    add_checksum(data)
  end

  # add checksum to the data
  def add_checksum(data)
    data << (data.inject(0) { |sum, x| sum + x } & 255)
  end

  # send command to serial device
  def send_command(command, return_bytes_length)
    command = convert_data(command)
    serial.write(command)
    serial.read(return_bytes_length)
  end

  # Convert data into bit/bytes?
  def convert_data(command)
    converted = ''
    command.each_char do |c|
      converted << c.chr
    end
    converted
  end

  # determine validity of control_command
  def process_control_command_return(data)
    return false unless valid?(data)
    true
  end

  # grouped validation
  def valid?(data)
    return false unless valid_handshake?(data)
    return false unless valid_bytes_back?(data)
    return false unless valid_checksum?(data)
    true
  end

  # Recieving data from controller
  def get_payload(data)
    payload = []
    sub_length = data.length - 1
    (2..sub_length).each do |byte|
      payload << data[byte, byte + 1].ord
    end
    payload
  end

  # Validation of Data
  def valid_handshake?(data)
    data[0, 1].ord == 170
  end

  def valid_bytes_back?(data)
    data[1, 2].ord == (data.length - 3)
  end

  def valid_checksum?(data)
    length = data.length
    sub_length = length - 1
    dsum = 0
    (0..sub_length).each do |byte|
      dsum += data[byte, byte + 1].ord
    end
    dsum & 255 == data[sub_length, length]
  end
end
