require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Lighthouse" do
  
  it "should be able to instantiate a new instance" do
    @ticketmaster = TicketMaster.new(:lighthouse, {:account => 'ticketmaster', :token => '000000'})
    @ticketmaster.should be_an_instance_of(TicketMaster)
    @ticketmaster.should be_a_kind_of(TicketMaster::Provider::Lighthouse)
  end
  
end
