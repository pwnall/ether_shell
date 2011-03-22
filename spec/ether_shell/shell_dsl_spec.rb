require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'ShellDsl' do
  let(:eth_device) { 'eth0' }
  let(:eth_type) { 0x0800 }
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
  
end
