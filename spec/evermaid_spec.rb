require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe "EverMaid" do
  it "should connect to Evernote" do
    my_ever = EverMaid.new
    my_ever.should_not be_nil
  end
  before(:all){
      @my_ever = EverMaid.new
      @test_note = @my_ever.get_note("c5fc1802-d068-4edd-9ba7-b8891ac5448a")
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
  
  it "should update tags on notes containing today's date" do
    notes_ref_today = @my_ever.search(Time.now.strftime("%F"))
    this_note_guid = notes_ref_today.notes.first.guid
    this_note = @my_ever.get_note(this_note_guid)
    @my_ever.is_tagged(this_note, "active").should eql(:no_tag)
    @my_ever.update_active(notes_ref_today)
    this_note = @my_ever.get_note(this_note_guid)
    @my_ever.is_tagged(this_note, "active").should eql(:has_tag)
    @my_ever.remove_tag(this_note, "active")
  end

  it "should return an error if checking for a field that doesn't exist" do
    my_note = @my_ever.get_note("c5fc1802-d068-4edd-9ba7-b8891ac5448a")
    @my_ever.check_for_field(my_note, "ha ha").should eql 1
  end

  it "should return the field when checking for a field that exists" do
    my_note = @my_ever.get_note("c5fc1802-d068-4edd-9ba7-b8891ac5448a")
    @my_ever.check_for_field(my_note, "EM-Review:").should eql("EM-Review: in one week")
  end

  it "should update the field with a date stamp" do
    future_date_tmp = DateTime.now + 7
    future_date = future_date_tmp.strftime("%F")
    @my_ever.magic_date_field("EM-Review: in one week").should eql("EM-Review: #{future_date}")
  end

  it "should check if a note contains a string" do
    my_note = @my_ever.get_note("c5fc1802-d068-4edd-9ba7-b8891ac5448a")
    @my_ever.check_content(my_note, "word").should eql(:has_content)
    @my_ever.check_content(my_note, "noth this").should eql(:no_content)
  end

  it "should update the note with a new date" do
    future_date_tmp = DateTime.now + 7
    future_date = future_date_tmp.strftime("%F")
    my_note = @my_ever.get_note("c5fc1802-d068-4edd-9ba7-b8891ac5448a")
    @my_ever.check_content(my_note, future_date).should eql(:no_content)
    @my_ever.update_field(my_note, "EM-Review")
    my_note = @my_ever.get_note("c5fc1802-d068-4edd-9ba7-b8891ac5448a")
    @my_ever.check_content(my_note, future_date).should eql(:has_content)
  end

  after(:all){
    @my_ever.update_entire_content(@test_note, @test_note.content)
  }

end
