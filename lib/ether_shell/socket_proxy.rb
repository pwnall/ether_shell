# :nodoc: namespace
module EtherShell

# Wraps an Ethernet socket and abstracts away the Ethernet II frame.
module SocketProxy
  # Creates a wrapper around a raw Ethernet socket.
  #
  # Args:
  #   raw_socket:: a raw Ethernet socket
  #   mac:: 6-byte MAC address for the Ethernet socket
  #   ether_type:: 2-byte Ethernet packet type number
  #
  # Raises:
  #   RuntimeError:: if mac isn't exactly 6-bytes long
  def initialize(raw_socket, mac_address, ether_type)
    check_mac mac
    
    @socket = raw_socket
    @source_mac = mac_address.dup
    @dest_mac = nil
    @ether_type = [ether_type].pack('n')
  end

  # Sets the destination MAC address for future calls to send.
  #
  # Args:
  #   mac:: 6-byte MAC address for the Ethernet socket
  #
  # Raises:
  #   RuntimeError:: if mac isn't exactly 6-bytes long
  def connect(mac_address)
    check_mac mac_address
    @dest_mac = mac_address
  end
  
  # Sends an Ethernet II frame.
  #
  # Args:
  #   data:: the data bytes to be sent
  #
  # Raises:
  #   RuntimeError:: if connect wasn' previously called
  def send(data, send_flags = 0)
    raise "Not connected" unless @dest_mac
    send_to @dest_mac, data, send_flags
  end
  
  # Sends an Ethernet II frame.
  #
  # Args:
  #   mac_address:: the destination MAC address
  #   data:: the data bytes to be sent
  #
  # Raises:
  #   RuntimeError:: if connect wasn' previously called
  def send_to(mac_address, data, send_flags = 0)
    check_mac mac_address

    padding = (data.length < 46) ? "\0" * (data.length - 46) : ''
    packet = [mac_address, @source_mac, @ether_type, data, padding].join
    @socket.send packet, send_flags
  end
  
  # Receives an Ethernet II frame.
  #
  # Args:
  #   buffer_size:: optional maximum packet size argument passed to the raw
  #                 socket's recv method
  #
  # Returns the data in the frame.
  #
  # This will discard incoming frames that don't match the MAC address that the
  # socket is connected to, or the Ethernet packet type.
  def recv(buffer_size = 8192)
    raise "Not connected" unless @dest_mac
    loop do
      mac_address, data = recv_from buffer_size
      return data if mac_address == @dest_mac
    end
  end
  
  # Receives an Ethernet II frame.
  #
  # Args:
  #   buffer_size:: optional maximum packet size argument passed to the raw
  #                 socket's recv method
  #
  # Returns the data in the frame.
  #
  # This will discard incoming frames that don't match the MAC address that the
  # socket is connected to, or the Ethernet packet type.
  def recv_from(buffer_size = 8192)
    loop do
      packet = @socket.recv buffer_size
      next unless packet[12, 2] == @ether_type
      next unless packet[0, 6] == @source_mac
      return packet[6, 12], packet[14..-1]
    end
  end
  
  # Raises an exception if the given MAC address is invalid.
  def check_mac(mac_address)
    raise "Invalid MAC address" unless mac_address.length == 6
  end
  private :check_mac
end

end  # namespace EtherShell
