class RawSocketStub
  def initialize(recv_data)
    @packets = recv_data
    @sends = []
  end
  
  def recv(buffer_size)
    raise 'recv called too many times' if @packets.empty?
    @packets.shift
  end
  
  def send(data, flags)
    raise 'Weird flags' if flags != 0
    @sends << data
  end

  attr_reader :sends
end
