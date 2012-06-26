require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TaskMapper::Provider::Lighthouse::Ticket do
  let(:headers) { {'X-LighthouseToken' => '000000'} }
  let(:wheaders) { {'Accept' => 'application/json'}.merge(headers) }
  let(:pheaders) { headers.merge('Content-Type' => 'application/json') }
  let(:project_id) { 54448 }
  let(:tm) { TaskMapper.new(:lighthouse, :account => 'taskmapper', :token => '000000') }
  let(:ticket_class) { TaskMapper::Provider::Lighthouse::Ticket }
  let(:ticket_id) { 5 }

  describe "Retrieving tickets" do 
    before(:each) do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/projects/54448.json', wheaders, fixture_for('projects/54448'), 200
        mock.get '/projects/54448/tickets/5.json', wheaders, fixture_for('tickets/5'), 200
        1.upto(100) do |page|
          mock.get "/projects/54448/tickets.json?limit=100&page=#{page}", wheaders, fixture_for('tickets'), 200
        end
      end
    end
    let(:project) { tm.project project_id }  

    context "when #tickets" do 
      subject { project.tickets } 
      it { should be_an_instance_of Array }
    end

    context "when #tickets with array of id's" do 
      subject { project.tickets [ticket_id] }
      it { should be_an_instance_of Array }
    end

    context "when #tickets with attributes" do 
      subject { project.tickets :id => ticket_id } 
      it { should be_an_instance_of Array }
    end

    describe "Retrieving single tickets" do 
      context "when #tickets.first" do 
        subject { project.tickets.first } 
        it { should be_an_instance_of ticket_class }
      end

      context "when #ticket with an id" do 
        subject { project.ticket ticket_id } 
        it { should be_an_instance_of ticket_class }
      end

      context "when #ticket with attributes" do 
        subject { project.ticket :id => ticket_id } 
        it { should be_an_instance_of ticket_class }
      end
    end
  end

  describe "Create & Update" do 
    before(:each) do 
      ActiveResource::HttpMock.respond_to do |mock|
        mock.get '/projects/54448.json', wheaders, fixture_for('projects/54448'), 200
        mock.post '/projects/54448/tickets.json', pheaders, fixture_for('tickets/create'), 200
      end
    end
    let(:project) { tm.project project_id } 

    context "when #ticket!" do 
      subject { project.ticket! :title => 'Ticket #12', :description => 'Body' } 
      it { should be_an_instance_of ticket_class }
    end
  end

  it "should be able to update and save a ticket" do
    pending
    @ticket = @project.ticket(5)
    @ticket.save.should == nil
    @ticket.description = 'hello'
    @ticket.save.should be_true
  end

end
