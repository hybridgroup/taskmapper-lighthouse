require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Lighthouse" do

  before(:each) do 
    @ticketmaster = TicketMaster.new(:lighthouse, {:account => 'ticketmaster', :token => '000000'})
    headers = {'X-LighthouseToken' => '000000'}
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects.xml', headers, fixture_for('projects'), 200
    end
  end

  it "should be able to instantiate a new instance" do
    @ticketmaster.should be_an_instance_of(TicketMaster)
    @ticketmaster.should be_a_kind_of(TicketMaster::Provider::Lighthouse)
  end

  it "should return true for a valid authentication" do 
    @ticketmaster.valid?.should be_true
  end

end
