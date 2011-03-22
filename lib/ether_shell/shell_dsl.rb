# :nodoc: namespace
module EtherShell

# Provides the Ethernet shell DSL.
#
# Include this in the evaluation context where you want the Ethernet shell DSL.
module ShellDsl
  # Creates a Ethernet socket for this shell.
  #
  # Args:
  #   eth_device:: an Ethernet device name, e.g. 'eth0'
  #   ether_type:: 2-byte Ethernet packet type number
  #   dest_mac:: MAC address of the endpoint to be tested; it can be a raw
  #              6-byte string, 
  def connect(eth_device, ether_type, dest_mac)
    raise "Already connected. did you forget to call disconnect?" if @_socket
    mac_bytes = __parse_mac_data dest_mac
    @_socket = EtherShell::HighSocket.new eth_device, ether_type
    @_socket.connect mac_bytes
    self
  end

  # Disconnects this shell's Ethernet socket.
  #
  # A socket should have been connected previously, using connect or socket. The
  # shell can take further connect and socket calls.
  def disconnect
    raise "Not connected. did you forget to call connect?" unless @_socket
    @_socket.close
    @_socket = nil
  end
  
  # Connects this shell to a pre-created socket
  #
  # Args:
  #   high_socket:: socket that behaves like an EtherShell::HighSocket
  def socket(high_socket)
    raise "Already connected. did you forget to call disconnect?" if @_socket
    @_socket = high_socket
    self
  end
  
  # Enables or disables the console output in out and expect.
  #
  # Args:
  #   true_or_false:: if true, out and expect will produce console output
  def verbose(true_or_false)
    @_verbose = verbose
    self
  end
  
  # Outputs a packet.
  #
  # Args:
  #   packet_data:: an Array of integers (bytes), a hex string starting with 0x,
  #                 or a string of raw bytes
  #
  # Raises:
  #   RuntimeError:: if the shell was not connected to a socket by a call to
  #                  connect or socket
  def out(packet_data)
    raise "Not connected. did you forget to call connect?" unless @_socket
    bytes = __parse_packet_data packet_data
    
    
    print "Sending #{bytes.unpack('H*').first}... " if @_verbose
    @_socket.send bytes
    print "OK\n" if @_verbose
    self
  end
  
  # Receives a packet and matches it against an expected value.
  #
  # Args:
  #   packet_data:: an Array of integers (bytes), a hex string starting with 0x,
  #                 or a string of raw bytes
  #
  # Raises:
  #   RuntimeError:: if the shell was not connected to a socket by a call to
  #                  connect or socket
  #   RuntimeError:: if the received packet doesn't match the expected value
  def expect(packet_data)
    raise "Not connected. did you forget to call connect?" unless @_socket
    expected_bytes = __parse_packet_data packet_data
    
    print "Receiving... " if @_verbose
    bytes = @_socket.recv
    print " #{bytes.unpack('H*').first} " if @_verbose
    if bytes == expected_bytes
      print "OK\n" if @_verbose
    else
      print " != #{expected_bytes.unpack('H*').first} ERROR\n" if @_verbose
      raise EtherShell::ExpectationError,
            "#{bytes.unpack('H*').first} != expected_bytes.unpack('H*').first"
    end
    self
  end
  
  # :nodoc: turns a packet pattern into a string of raw bytes
  def __parse_packet_data(packet_data)
    if packet_data.kind_of? Array
      # Array of integers.
      packet_data.pack('C*')
    elsif packet_data.kind_of? String
      if packet_data[0, 2] == '0x'
        [packet_data[2..-1]].pack('H*')
      else
        packet_data
      end
    end
  end
  private :__parse_packet_data

  # :nodoc: turns a packet pattern into a string of raw bytes
  def __parse_mac_data(mac_data)
    if mac_data.length == 12
      mac_data.unpack('H*').first
    elsif mac_data.length == 14 && mac_data[0, 2] == '0x'
      mac_data[2, 12].unpack('H*').first
    elsif mac_data.kind_of? Array
      mac_data.pack('C*')
    else
      mac_data
    end
  end
  private :__parse_mac_data
end  # module EtherShell::ShellDsl

end  # namespace EtherShell
