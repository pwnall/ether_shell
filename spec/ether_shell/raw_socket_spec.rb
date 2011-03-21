require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'RawSocket' do
  let(:eth_device) { 'eth0' }
  
  describe 'mac' do
    let(:mac) { EtherShell::RawSocket.mac eth_device }
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
end
