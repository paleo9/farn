
# encoding: utf-8
require '../farn_page_parser'
require 'mongo'
include Mongo

# perform a variety of tests on one file
# usage ruby [ruby_options] farn_page_parser_test <infile> <outfile> 

FILENAME_IN = ARGV[0]
DB = 'farn_test_db'
COLLECTION = 'farn_page'

# init db
client = MongoClient.new
warn 'this will remove the test database'
client.db.collection(COLLECTION).remove  # start with empty test database
db = client.db(DB)
coll = db.collection(COLLECTION)

fp = FarnPageParser.new
if File.directory?(FILENAME_IN)
   fname = "#{FILENAME_IN}\/#{file}"
   Dir.foreach(fname) do |file|
   unless File.directory?(fname)
     puts "inserting #{fname}"
     #fp.parse_file(fname)
     #hash = fp.to_hash
     # coll.insert hash 
     #  puts "#{FILENAME_IN}: #{fp.rows.size} rows."
   end
  end
else
  warn "Error, #{FILENAME_IN} is not a directory\n"
end

puts "Inserted #{coll.count} documents\n"

# parse file

out.puts doc.to_s


