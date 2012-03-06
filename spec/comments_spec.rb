require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Lighthouse::Comment" do
  before(:all) do
    headers = {'X-LighthouseToken' => '000000'}
    wheaders = headers.merge('Content-Type' => 'application/xml')
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects/54448.xml', headers, fixture_for('projects/54448'), 200
      mock.get '/projects/54448/tickets.xml', headers, fixture_for('tickets'), 200
      mock.get '/projects/54448/tickets/2.xml', headers, fixture_for('tickets/2'), 200
      mock.put '/projects/54448/tickets/2.xml', wheaders, '', 200
    end
    @project_id = 54448
  end
  
  before(:each) do
    @ticketmaster = TicketMaster.new(:lighthouse, :account => 'ticketmaster', :token => '000000')
    @project = @ticketmaster.project(@project_id)
    @ticket = @project.ticket(2)
    @klass = TicketMaster::Provider::Lighthouse::Comment
  end
  
  it "should be able to load all comments" do
    @comments = @ticket.comments
    @comments.should be_an_instance_of(Array)
    @comments.first.should be_an_instance_of(@klass)
  end
  
  it "should be able to load all comments based on 'id's" do # lighthouse comments don't have ids, so we're faking them
    @comments = @ticket.comments([0,2,3])
    @comments.should be_an_instance_of(Array)
    @comments.first.id.should == 0
    @comments.last.id.should == 3
    @comments[1].should be_an_instance_of(@klass)
  end
  
  it "should be able to load all comments based on attributes" do
    @comments = @ticket.comments(:number => @ticket.id)
    @comments.should be_an_instance_of(Array)
    @comments.first.should be_an_instance_of(@klass)
  end
  
  it "should be able to load a comment based on id" do
    @comment = @ticket.comment(3)
    @comment.should be_an_instance_of(@klass)
    @comment.id.should == 3
  end
  
  it "should be able to load a comment based on attributes" do
    @comment = @ticket.comment(:number => @ticket.id)
    @comment.should be_an_instance_of(@klass)
  end
  
  it "should return the class" do
    @ticket.comment.should == @klass
  end
  
  it "should be able to create a comment" do # which as mentioned before is technically a ticket update
    pending
    @test = @klass.find_by_id(54448, 2, 10)
    @klass.should_receive(:find_by_id).with(54448, 2, 11).and_return(@test)
    @comment = @ticket.comment!(:body => 'hello there boys and girls')
    @comment.should be_an_instance_of(@klass)
  end
end
