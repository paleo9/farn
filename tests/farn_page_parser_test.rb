# encoding: utf-8
require '../farn_page_parser'
require 'mongo'
include Mongo

# perform a variety of tests on one file
# usage ruby [ruby_options] farn_page_parser_test <infile> <outfile> 

FILENAME_IN = ARGV[0]
FILENAME_OUT = ARGV[1]
DB = 'farn_test_db'
COLLECTION = 'farn_page'

# init files
fout = File.open(FILENAME_OUT,'w')

# init db
client = MongoClient.new
client.db.collection(COLLECTION).remove  # start with empty test database
db = client.db(DB)
coll = db.collection(COLLECTION)

# parse file
fp = FarnPageParser.new
fp.parse_file(FILENAME_IN)

fout.puts "Testing #{FILENAME_IN}\n"
fout.puts "name: #{fp.name}"
fout.puts "query date: #{fp.query_date}"
fout.puts "found #{fp.rows.size} rows"
hash = fp.to_hash
fout.puts "\nTesting to_hash\n"
fout.puts hash 
coll.insert hash
fout.puts "Testing mongodb find_one\n"
doc = coll.find_one
fout.puts doc.to_s

fout.close


