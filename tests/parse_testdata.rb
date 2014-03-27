#encoding: utf-8

require './farn_page_parser.rb'
fout = File.open('example.txt','w')
processed = File.open('processing.txt','w')
fp = FarnPageParser.new

filenames = Dir.glob("testdata/aaa/*.ht*")
filenames.sort.each do |f|
  processed.write("#{f}\n")
  fp.parse_file(f)
  fout.puts "//****** HERE #{f} ******//\n"
  fout.puts fp.to_s
end
processed.close
fout.close
