require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Lighthouse" do
  before(:each) do
    @account = 'ticketmaster'
    @token = '00c00123b00f00dc0de'
    @lhproject = LighthouseAPI::Project.new
    LighthouseAPI.should_receive(:'account=').with(@account).any_number_of_times.and_return(@account)
    LighthouseAPI.should_receive(:'token=').with(@token).any_number_of_times.and_return(@token)
    @lhproject.attributes = {"permalink"=>"lh-test", "name"=>"lh-test", "created_at"=>Time.now, "description_html"=>"<div><p>This is a test project created in order to test the\nticketmaster-lighthouse gem.</p></div>", "closed_states_list"=>"resolved,hold,invalid", "public"=>true, "default_ticket_text"=>nil, "license"=>nil, "default_milestone_id"=>nil, "closed_states"=>"resolved/6A0 # You can customize colors\nhold/EB0     # with 3 or 6 character hex codes\ninvalid/A30  # 'A30' expands to 'AA3300'", "updated_at"=>Time.now, "archived"=>false, "send_changesets_to_events"=>true, "open_states_list"=>"new,open", "open_tickets_count"=>2, "id"=>54448, "default_assigned_user_id"=>nil, "description"=>"This is a test project created in order to test the ticketmaster-lighthouse gem.", "open_states"=>"new/f17  # You can add comments here\nopen/aaa # if you want to.", "hidden"=>false}
    LighthouseAPI::Project.should_receive(:find).with(:all).any_number_of_times.and_return([@lhproject])
    @lighthouse = TicketMaster.new(:lighthouse, {:token => @token, :account => @account})
    @project = @lighthouse.project['lh-test']
  end
  
  it "should be able to find projects" do
    @project.is_a?(TicketMasterMod::Project).should == true
    @lhproject.attributes.each do |k, v|
      @project.send(k).should == v
    end
  end
  
  it "should be able to find tickets" do
    @tickets = []
    lh = LighthouseAPI::Ticket.new
    lh.attributes = {"permalink"=>"test-ticket", "number"=>2, "milestone_id"=>nil, "created_at"=>Time.now, "title"=>"Cheese cakes", "updated_at"=>Time.now, "raw_data"=>nil, "closed"=>false, "priority"=>2, "attachments_count"=>0, "tag"=>nil, "url"=>"http://ticketmaster.lighthouseapp.com/projects/54448/tickets/2", "milestone_due_on"=>nil, "creator_id"=>67916, "original_body_html"=>"<div><p>This is a test</p></div>", "user_id"=>67916, "original_body"=>"This is a test", "user_name"=>"Kia Kroas", "assigned_user_id"=>nil, "latest_body"=>"This is a test", "state"=>"new", "creator_name"=>"Kia Kroas"}
    lh.prefix_options= {:project_id=>54448}
    @tickets << lh
    @project.should_receive(:tickets).any_number_of_times.and_return(@tickets)
    @project.tickets.each do |ticket|
      ticket.attributes.each do |k, v|
        ticket.send(k).should == v
      end
    end
  end
end
