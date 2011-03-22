require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ShellDsl' do
  let(:eth_device) { 'eth0' }
  let(:eth_type) { 0x0800 }
  let(:mac) { EtherShell::RawSocket.mac eth_device }
  let(:dest_mac) { "\x00\x11\x22\x33\x44\x55" }
  let(:bcast_mac) do
    string = "\xff" * 6
    # Awful hack so the MAC matches any packet.
    class <<string
      def ==(other)
        other.respond_to?(:length) && other.length == 6
      end
    end
    string
  end

  let(:shell) { ShellStub.new }

  shared_examples_for 'a connected shell' do
    it 'should be able to send a packet' do
      shell.out 'Shell test packet'
    end
    
    it 'should be able to receive noise' do
      lambda {
        shell.expect 'Impossible pattern'
      }.should raise_error(EtherShell::ExpectationError)
    end
    
    it 'should not connect again' do
      lambda {
        shell.connect eth_device, eth_type, bcast_mac
      }.should raise_error(RuntimeError)
    end
    
    it 'should not accept a socket again' do
      raw_socket = EtherShell::HighSocket.new eth_device, eth_type
      lambda {
        shell.socket raw_socket
      }.should raise_error(RuntimeError)
      raw_socket.close
    end
  end

  describe 'connected to new socket' do
    before { shell.connect eth_device, eth_type, bcast_mac }
    after { shell.disconnect }
    
    it_should_behave_like 'a connected shell'
  end
  
  describe 'connected to a live socket' do
    let(:live_socket) do
      socket = EtherShell::HighSocket.new eth_device, eth_type
      socket.connect bcast_mac
      socket
    end
    before { shell.socket live_socket }
    after { shell.disconnect }
    
    it_should_behave_like 'a connected shell'
  end
  
  
  describe 'disconnected' do
    it 'should not send packets' do
      lambda {
        shell.out 'Will never go out'
      }.should raise_error(RuntimeError)
    end
    
    it 'should not expect packets' do
      lambda {
        shell.expect 'Impossible pattern'
      }.should raise_error(RuntimeError)
    end
  end
  
  describe 'connected to stubs' do
    let(:socket_stub) do
      RawSocketStub.new([
        [mac, dest_mac, "\x88\xB7", 'Wrong Ethernet type'].join,
        [bcast_mac, dest_mac, [eth_type].pack('n'), 'Wrong dest MAC'].join,
        [mac, bcast_mac, [eth_type].pack('n'), 'Bcast'].join,
        [mac, dest_mac, [eth_type].pack('n'), "\xC0\xDE\xAA\x13\x37"].join,
      ])
    end
    let(:stubbed_shell_socket) do
      socket = EtherShell::HighSocket.new socket_stub, eth_type, mac
      socket.connect dest_mac
      socket
    end
    before { shell.socket stubbed_shell_socket }
    
    let(:golden_sends) do
      [
        [dest_mac, mac, [eth_type].pack('n'), "\x13\x37\xAA\xC0\xDE",
         "\0" * 41].join
      ]
    end
    
    it 'should send raw packet' do
      shell.out "\x13\x37\xAA\xC0\xDE"
      socket_stub.sends.should == golden_sends
    end
    
    it 'should send array packet' do
      shell.out [0x13, 0x37, 0xAA, 0xC0, 0xDE]
      socket_stub.sends.should == golden_sends
    end

    it 'should send hex packet' do
      shell.out '0x1337AAC0DE'
      socket_stub.sends.should == golden_sends
    end

    it 'should expect raw packet' do
      lambda {
        shell.expect "\xC0\xDE\xAA\x13\x37"
      }.should_not raise_error
    end
    
    it 'should expect array packet' do
      lambda {
        shell.expect [0xC0, 0xDE, 0xAA, 0x13, 0x37]
      }.should_not raise_error
    end

    it 'should expect hex packet' do
      lambda {
        shell.expect '0xC0DEAA1337'
      }.should_not raise_error
    end
    
    it 'should raise on expectation mismatch' do
      lambda {
        shell.expect '0xC0DEAA1338'
      }.should raise_error(EtherShell::ExpectationError)
    end
  end
end
