require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Lighthouse::Ticket" do
  before(:all) do
    headers = {'X-LighthouseToken' => '000000'}
    wheaders = headers.merge('Content-Type' => 'application/xml')
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects/54448.xml', headers, fixture_for('projects/54448'), 200
      mock.get '/projects/54448/tickets.xml', headers, fixture_for('tickets'), 200
      1.upto(100) do |page|
        mock.get "/projects/54448/tickets.xml?limit=100&page=#{page}", headers, fixture_for('tickets'), 200
      end
      mock.get '/projects/54448/tickets/5.xml', headers, fixture_for('tickets/5'), 200
      mock.put '/projects/54448/tickets/5.xml', wheaders, '', 200
      mock.post '/projects/54448/tickets.xml', wheaders, fixture_for('tickets/create'), 200
    end
    @project_id = 54448
  end

  before(:each) do
    @ticketmaster = TicketMaster.new(:lighthouse, :account => 'ticketmaster', :token => '000000')
    @project = @ticketmaster.project(@project_id)
    @klass = TicketMaster::Provider::Lighthouse::Ticket
  end

  it "should be able to load all tickets" do
    @project.tickets.should be_an_instance_of(Array)
    @project.tickets.first.should be_an_instance_of(@klass)
  end

  it "should be able to load all tickets based on an array of ids" do
    @tickets = @project.tickets([5])
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.id.should == 5
  end

  it "should be able to load all tickets based on attributes" do
    @tickets = @project.tickets(:id => 5)
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.id.should == 5
  end

  it "should return the ticket class" do
    @project.ticket.should == @klass
  end

  it "should be able to load a single ticket" do
    @ticket = @project.ticket(5)
    @ticket.should be_an_instance_of(@klass)
    @ticket.id.should == 5
  end

  it "should be able to load a single ticket based on attributes" do
    @ticket = @project.ticket(:id => 5)
    @ticket.should be_an_instance_of(@klass)
    @ticket.id.should == 5
  end

  it "should be able to update and save a ticket" do
    pending
    @ticket = @project.ticket(5)
    @ticket.save.should == nil
    @ticket.description = 'hello'
    @ticket.save.should be_true
  end

  it "should be able to create a ticket" do
    @ticket = @project.ticket!(:title => 'Ticket #12', :description => 'Body')
    @ticket.should be_an_instance_of(@klass)
  end

end
