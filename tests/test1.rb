# encoding: utf-8
require 'farn_page_parser'

# General, ad hoc tests to test progress during development.
# Not to be considered proper tests.

fout = File.open('test.out', 'w')
parser = FarnPageParser.new
parser.parse_file('example.html')
h = parser.to_hash
# fout.puts h.inspect
fout.puts parser.rows[0].to_hash(parser.properties_headings).inspect
fout.close

