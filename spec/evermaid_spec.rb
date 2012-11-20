require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe "EverMaid" do
  it "should connect to Evernote" do
    my_ever = EverMaid.new
    my_ever.should_not be_nil
  end
  before(:all){
      @my_ever = EverMaid.new
  }


  it "should list one notebook" do
    @my_ever.notebooks.length.should eql(1)
  end
end
