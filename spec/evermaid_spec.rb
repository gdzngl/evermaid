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

  it "should list all users tags" do
    @my_ever.tags.should include("active")
  end


  it "should get a note" do
    my_note = @my_ever.get_note("c5fc1802-d068-4edd-9ba7-b8891ac5448a")
    my_note.should be_an_instance_of(Evernote::EDAM::Type::Note)
  end
  

  it "should check if a note has a tag" do
    my_note = @my_ever.search("word").notes.first
    @my_ever.is_tagged(my_note, "my_tag").should eql(:has_tag)
    @my_ever.is_tagged(my_note, "my_new_tag").should eql(:no_tag)
  end
  ## TODO ##
  it "should update tags on notes containing today's date" do
    notes_ref_today = @my_ever.search(Time.now.strftime("%F"))
    this_note_guid = notes_ref_today.notes.first.guid
    this_note = @my_ever.get_note(this_note_guid)
    @my_ever.is_tagged(this_note, "active").should eql(:no_tag)
    @my_ever.update_active(notes_ref_today)
    this_note = @my_ever.get_note(this_note_guid)
    @my_ever.is_tagged(this_note, "active").should eql(:has_tag)
  end
end
