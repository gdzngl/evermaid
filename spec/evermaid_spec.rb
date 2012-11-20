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

  it "should return search results" do
    @my_ever.search("word").should be_an_instance_of(Evernote::EDAM::NoteStore::NoteList)
  end

  it "should return notes containing today's date" do
    notes_ref_today = @my_ever.search(Time.now.strftime("%F"))
    notes_ref_today.totalNotes.should eql(1)
  end

  #it "should update tags on notes containing today's date" do
    #notes_ref_today = @my_ever.search(Time.now.strftime("%F"))

    #notes_ref_today.notes.first
    #p notes_ref_today.notes.class

  #end
end
