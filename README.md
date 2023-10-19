farn
====
# ARCHIVED 2023
This repository was for a web scraping project using ruby. The site that it was 
designed to examine will have changed its html long ago. I am keeping it as a read-only 
archive as an aide memoir for ruby syntax. 

Farn files are pretty big, thousands of lines long. These scripts help to extract 
the few dozen lines that are of interest.
Go to farn, perform a search and save the resulting page. Then use FarnPageParser
parse_page(filename) to parse it. You can output it as a hash or a string, using
to_hash and to_s respectively. 

Rationale
=========

This app is a content scraper to work on Farn files. Ruby libraries for working 
with HTML were difficult to use on this project as Farn files do not contain 
valid HTML and the content to be extracted was not consistent in its construction. 
It was more therefore, an exercise in regular expressions. This program uses a 
single class (and a couple of internal helper classes) that expects a file location. 
It outputs JSON.

Code style has been checked with rubocop and documentation produced by rdoc.

The tests directory contains a few example ruby test scripts that act on test data 
in the testdata directory poducing results for JSON and MongoDB.
