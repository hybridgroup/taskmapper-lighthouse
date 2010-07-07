require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster" do
  before(:each) do
    @ticketmaster = TicketMaster.new(:lighthouse, :token => '00c00123b00f00dc0de', :account => 'ticketmaster')
    @project_class = TicketMaster::Provider::Lighthouse::Project
    @ticket_class = TicketMaster::Provider::Lighthouse::Ticket
    @lh_project = LighthouseAPI::Project.new
    @lh_project.attributes = {"permalink"=>"lh-test", "name"=>"lh-test", "created_at"=>Time.now, "description_html"=>"<div><p>This is a test project created in order to test the\nticketmaster-lighthouse gem.</p></div>", "closed_states_list"=>"resolved,hold,invalid", "public"=>true, "default_ticket_text"=>nil, "license"=>nil, "default_milestone_id"=>nil, "closed_states"=>"resolved/6A0 # You can customize colors\nhold/EB0     # with 3 or 6 character hex codes\ninvalid/A30  # 'A30' expands to 'AA3300'", "updated_at"=>Time.now, "archived"=>false, "send_changesets_to_events"=>true, "open_states_list"=>"new,open", "open_tickets_count"=>2, "id"=>54448, "default_assigned_user_id"=>nil, "description"=>"This is a test project created in order to test the ticketmaster-lighthouse gem.", "open_states"=>"new/f17  # You can add comments here\nopen/aaa # if you want to.", "hidden"=>false}
    @lh_project.prefix_options = {}
    
  end
  
  # Essentially just a sanity check on the include since .new always returns the object's instance
  it "should be able to instantiate a new instance" do
    @ticketmaster.should be_an_instance_of TicketMaster
    @ticketmaster.should be_a_kind_of TicketMaster::Provider::Lighthouse
  end
  
  it "should be able to load projects" do
    LighthouseAPI::Project.should_receive(:find).with(:all).at_least(:once).and_return([@lh_project])
    @ticketmaster.projects.should be_an_instance_of Array
    @ticketmaster.projects.first.should be_an_instance_of @project_class
    @ticketmaster.projects.first.description.should == @lh_project.attributes['description']
    @ticketmaster.projects(:id => 54448).should be_an_instance_of Array
    @ticketmaster.projects(:id => 54448).first.should be_an_instance_of @project_class
    @ticketmaster.projects(:id => 54448).first.id.should == 54448
    
    @ticketmaster.project.should == @project_class
    @ticketmaster.project(:name => "lh-test").should be_an_instance_of @project_class
    @ticketmaster.project(:name => "lh-test").name.should == "lh-test"
    @ticketmaster.project.find(:first, :description => @lh_project.attributes['description']).should be_an_instance_of @project_class
    @ticketmaster.project.find(:first, :description => @lh_project.attributes['description']).description.should == @lh_project.attributes['description']
  end
  
  it "should be able to do project stuff" do
    info = {:name => 'Test create'}
    LighthouseAPI::Project.should_receive(:new).at_least(:once).and_return(@lh_project)
    @lh_project.should_receive(:save).at_least(:once).and_return(true)
    @ticketmaster.project.create(info).should be_an_instance_of @project_class
    @ticketmaster.project.new(info).should be_an_instance_of @project_class
    @ticketmaster.project.create(info).id.should == 54448
  end
  
  it "should be able to load tickets" do
    LighthouseAPI::Project.should_receive(:find).with(:all).at_least(:once).and_return([@lh_project])
    LighthouseAPI::Ticket.should_receive(:find).with(:all, :params => {:project_id => 54448}).at_least(:once).and_return([LighthouseAPI::Ticket.new])
    LighthouseAPI::Ticket.should_receive(:find).with(999, :params => {:project_id => 54448}).at_least(:once).and_return(LighthouseAPI::Ticket.new(:id => 999))
    project = @ticketmaster.projects.first
    project.tickets.should be_an_instance_of Array
    project.tickets.first.should be_an_instance_of @ticket_class
    project.tickets([999]).should be_an_instance_of Array
    project.tickets([999]).first.should  be_an_instance_of @ticket_class
    #project.tickets([999]).first.id.should == 999
    
    project.ticket.should ==  TicketMaster::Provider::Lighthouse::Ticket
    project.ticket(999).should be_an_instance_of @ticket_class
    #project.ticket(999).id.should == 999
  end
end
