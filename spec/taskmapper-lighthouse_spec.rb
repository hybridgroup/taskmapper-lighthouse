require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TaskMapper::Provider::Lighthouse" do

  before(:each) do 
    @taskmapper = TaskMapper.new(:lighthouse, {:account => 'taskmapper', :token => '000000'})
    headers = {'X-LighthouseToken' => '000000'}
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects.json', headers, fixture_for('projects'), 200
    end
  end

  it "should be able to instantiate a new instance" do
    @taskmapper.should be_an_instance_of(TaskMapper)
    @taskmapper.should be_a_kind_of(TaskMapper::Provider::Lighthouse)
  end

  it "should return true for a valid authentication" do 
    @taskmapper.valid?.should be_true
  end

end
