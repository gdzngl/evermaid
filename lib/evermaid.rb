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

  def search(query)
    @noteStore.findNotes(AUTH_TOKEN, "word")
  end
end


