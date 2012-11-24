require 'chronic'
require 'evernote-thrift'
require_relative 'token.rb'

class EverMaid
  def initialize
    userStoreUrl = "https://#{E_HOST}/edam/user"

    userStoreTransport = Thrift::HTTPClientTransport.new(userStoreUrl)
    userStoreProtocol = Thrift::BinaryProtocol.new(userStoreTransport)
    userStore = Evernote::EDAM::UserStore::UserStore::Client.new(userStoreProtocol)

    versionOK = userStore.checkVersion("Evernote EDAMTest (Ruby)",
               Evernote::EDAM::UserStore::EDAM_VERSION_MAJOR,
               Evernote::EDAM::UserStore::EDAM_VERSION_MINOR)
    exit(1) unless versionOK

    noteStoreUrl = userStore.getNoteStoreUrl(AUTH_TOKEN)

    noteStoreTransport = Thrift::HTTPClientTransport.new(noteStoreUrl)
    noteStoreProtocol = Thrift::BinaryProtocol.new(noteStoreTransport)
    @noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)
  end

  def notebooks
    @noteStore.listNotebooks(AUTH_TOKEN)
  end

  def get_filter(search_string)
    filter = Evernote::EDAM::NoteStore::NoteFilter.new
    filter.words = search_string
    #filter.order = Evernote::EDAM::Type::NoteSortOrder::UPDATED
    return filter
  end

  def search(query)
    my_filter = get_filter(query)
    @noteStore.findNotes(AUTH_TOKEN, my_filter, 0, 10)
  end

  def tags
    @my_tags = {}
    evernote_tags = @noteStore.listTags(AUTH_TOKEN)
    for item in evernote_tags
      @my_tags["#{item.name}"] = item.guid
    end
    return @my_tags
  end

  def get_note(guid)
    @noteStore.getNote(AUTH_TOKEN, guid, 1, 0, 0, 0)
  end

  def is_tagged(note, tag)
    does_it_have_the_tag = :no_tag
    my_tags = tags
    unless note.tagGuids.nil?
      for item in note.tagGuids
        if tags.key(item) == tag
          does_it_have_the_tag = :has_tag
        end
      end
    end
    return does_it_have_the_tag
  end

  def update_active(notes)
    for item in notes.notes
      if is_tagged(item, "active") == :has_tag
        next
      else
        note_to_update = get_note(item.guid)
        if note_to_update.tagGuids.nil?
          note_to_update.tagGuids = []
        end
        note_to_update.tagGuids << @my_tags["active"]
        @noteStore.updateNote(AUTH_TOKEN, note_to_update)
      end
    end
  end

  def remove_tag(note, tag)
    this_note = get_note(note.guid)
    if this_note.tagGuids.include?(@my_tags[tag])
      this_note.tagGuids.delete(@my_tags[tag])
      @noteStore.updateNote(AUTH_TOKEN, this_note)
    end
  end

  def check_for_field(note, field)
    split_content = note.content.split('<')
    p split_content
    for item in split_content
      if item.include?(field)
        return item.split('>').last
      end
    end
    return 1
  end

  def magic_date_field(field)
    my_field = field.split(':')
    if my_field.length > 2
      puts "SOMETHING IS WRONG #{my_field}"
    else
      return "#{my_field[0]}: #{Chronic.parse(my_field[1]).strftime("%F")}"
    end
  end

  def update_entire_content(note, new_content)
    note.content = new_content
    @noteStore.updateNote(AUTH_TOKEN, note)
  end

  def check_content(note, search)
    note_has_search_term = :no_content
    unless note.content.nil?
      if note.content.include?(search)
        note_has_search_term = :has_content
      end
    end
    return note_has_search_term
  end

  def update_field(note, field)
    field_with_data = check_for_field(note, field)
    new_field = magic_date_field(field_with_data)
    note.content.gsub!(field_with_data, new_field)
    @noteStore.updateNote(AUTH_TOKEN, note)
  end
end


