require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'RawSocket' do
  let(:eth_device) { 'eth0' }
  let(:mac) { EtherShell::RawSocket.mac eth_device }
  
  describe 'mac' do
    let(:golden_mac) do
      hex_mac = `ifconfig #{eth_device}`[/HWaddr .*$/][7..-1]
      [hex_mac.gsub(':', '').strip].pack('H*')
    end
    
    it 'should have 6 bytes' do
      mac.length.should == 6
    end
    
    it 'should match ifconfig output' do
      mac.should == golden_mac
    end
  end
  
  describe 'socket' do
    before { @socket = EtherShell::RawSocket.socket eth_device }
    after { @socket.close }
    
    it 'should be able to receive data' do
      @socket.should respond_to(:recv)
    end
    
    it 'should output a packet' do
      packet = [mac, mac, [0x88B7].pack('n'), "\r\n" * 32].join
      @socket.send packet, 0
    end

    it 'should receive some network noise' do
      packet = [mac, mac, [0x88B7].pack('n'), "\r\n" * 32].join
      @socket.recv(8192).should_not be_empty
    end
  end
end
