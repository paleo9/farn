#encoding: utf-8

require '../farn_page_parser.rb'
out_dir = 'results'
warn "Writing any output files to directory #{out_dir}"
fp = FarnPageParser.new

filenames = Dir.glob("testdata/aaa/*.ht*")
filenames.sort.each do |f|
  warn "*** Parsing #{f} ***"
  fout = File.open("#{out_dir}/#{File.basename(f)}.txt", 'w')
  fp.parse_file(f)
  fout.puts fp.to_s
  fout.close
end
