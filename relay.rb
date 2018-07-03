require 'rubyserial'

# -------------------------------------------------------- #
# This class is a interface between a NCD serial relay
# and ruby.
# -------------------------------------------------------- #
class Relay
  def initialize(device:, baudrate: 115_200, bytesize: 8)
    @serial = Serial.new device, baudrate, bytesize
  end

  # turn on a relay
  # @param [Integer] relay Index of relay to operate on.
  # @return [Boolean] Success?
  def on(relay)
    lsb = relay - 1 & 255
    msb = relay >> 8
    command = wrap_in_api([254, 48, lsb, msb]) # command:[]
    result = send_command(command) # result:string
    process_control_command_return(result)
  end

  # turn off a relay
  # @param [Integer] relay Index of relay to operate on.
  # @return [Boolean] Success?
  def off(relay)
    lsb = relay - 1 & 255
    msb = relay >> 8
    command = wrap_in_api([254, 47, lsb, msb])
    result = send_command(command)
    process_control_command_return(result)
  end

  private

  attr_reader :serial

  # @param [Array<Integer>] data A sequence of data.
  # @return [Array<Integer>] data A sequence of data, API wrapped, w/ checksum.
  def wrap_in_api(data)
    bytes_in_packet = data.length
    data = data.unshift(bytes_in_packet)
    data = data.unshift(170)
    add_checksum(data)
  end

  # @param [Array<Integer>] data A sequence of data.
  # @return [Array<Integer>] data A sequence of data, with appended checksum.
  def add_checksum(data)
    data << (data.inject(0) { |sum, x| sum + x } & 255)
  end

  # @param [Array<Integer>] command A sequence of data.
  # @param [Integer] return_bytes_length A length of bytes to expect back.
  # @return [String]
  def send_command(command, return_bytes_length = 4)
    command = convert_data(command) # command:string
    serial.write(command) # command:string
    serial.read(return_bytes_length)
  end

  # Convert data into bit/bytes?
  # @param [Array<Integer>] command A sequence of data.
  # @return [String] Converted bytes to bits
  def convert_data(command)
    converted = ''
    command.each do |c|
      converted << c.chr
    end
    converted
  end

  # @params [String] data String response from serial.
  # @return [Boolean] Success?
  def process_control_command_return(data)
    return false unless valid?(data)
    true
  end

  # @params [String] data String response from serial.
  # @return [Boolean] Sucess?
  def valid?(data)
    return false unless valid_handshake?(data)
    return false unless valid_bytes_back?(data)
    return false unless valid_checksum?(data)
    true
  end

  # @params [String] data String response from serial.
  # @return [Boolean] Success?
  def valid_handshake?(data)
    puts 'Handshake Data: '
    puts data
    data[0, 1].ord == 170
  end

  # @params [String] data String response from serial.
  # @return [Boolean] Success?
  def valid_bytes_back?(data)
    puts 'Valid Bytes Back: '
    puts data
    data[1, 2].ord == (data.length - 3)
  end

  # @params [String] data String response from serial.
  # @return [Boolean] Success?
  def valid_checksum?(data)
    puts 'Valid Checksum: '
    put data
    length = data.length
    sub_length = length - 1
    dsum = 0
    (0..sub_length).each do |byte|
      dsum += data[byte, byte + 1].ord
    end
    dsum & 255 == data[sub_length, length]
  end
end
