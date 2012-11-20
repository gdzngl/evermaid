require 'evernote-thrift'
require_relative 'token.rb'

evernoteHost = "sandbox.evernote.com"
userStoreUrl = "https://#{evernoteHost}/edam/user"

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
noteStore = Evernote::EDAM::NoteStore::NoteStore::Client.new(noteStoreProtocol)


# List all of the notebooks in the user's account
notebooks = noteStore.listNotebooks(AUTH_TOKEN)
puts "Found #{notebooks.size} notebooks:"
defaultNotebook = notebooks.first
notebooks.each do |notebook|
  puts "  * #{notebook.name}"
end
