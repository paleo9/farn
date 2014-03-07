# encoding: utf-8

require 'json'

# Extract useful information from a page resulting from performing save-as on a
# query at Farnell. It can be retreived as a hash (to_hash) or a string (to_s).

# Class FarnPageParser
# Parses and stores the information from the resulting page of a
# search performed on their website and subsequently stored by the user.
#
class FarnPageParser
# The kind of part e.g. 'Through-hole resistors'
  attr_reader :name

# The date on which the search was performed.
  attr_reader :query_date

# Headings common to all searches.
  attr_reader :headings

# Headings for the set of part properties. They vary, depending on part type
# e.g. resistors will include 'Resistance'. These may be used as an argument to
# rows[] row #to_hash.
  attr_reader :properties_headings

# An array containing each row from the results table.
  attr_reader :rows

# Returns a new FarnPageParser. @rows and @properties_headings are empty
# arrays; @headings are populated with the four unchanging column headings.
  def initialize
    @rows = []
    @headings = ['Order code', 'PDF', 'Web page', 'Manufacturer code']
    @properties_headings = []
  end

# Populates the attributes using the supplied file.
# filename: The saved web page to be parsed.
  def parse_file(filename)
    page = File.open(filename, 'r').read.tr!("\n", '')
    parse_query_date(page)
    parse_name(page)
    parse_properties_headings(page)
    parse_table_rows(page)
  end

# Returns a string of the all attributes.
  def to_s
    s = "Name: #{@name} Query date: #{query_date} Headings: "
    s += headings.to_s
    s += properties_headings.to_s
    rows.each { |r| s += r.to_s }
    s
  end

# Returns a hash of all the attributes; suitable for passing to to_json.
  def to_hash
    hash = { name: @name, query_date: @query_date }
    hash[:rows] = []
    @rows.each_with_index do |r, i|
      hash[:rows] << r.to_hash(@properties_headings)
    end
    hash
  end

# Returns a Json representation
  def to_json
    to_hash.to_json
  end

  private

# Extracts @query_date
  def parse_query_date(page)
    m = %r|\d{4}/\d{1,2}/\d{1,2}|
    @query_date = m.match(page).to_s
  end

# Extracts @name
  def parse_name(page)
    m = /<h1.*?>(?'name'.*?):/.match page
    @name = m[:name]
  end

# Extracts @properties_headings from the results table
  def parse_properties_headings(page)
    pattern =  /resultsHead1">(.*?)<\/th>/
    m = page.scan pattern
    m.each { |h| @properties_headings += h }
  end

# Extracts each row from the results table
# Each row begins with <tr...column_heading..
  def parse_table_rows(page)
    f = ['<tr><td id="results\.column-heading-compare_data_',
         '<td id="results\.column-heading-parametrics_data_',
         '<\/td>\s*<\/tr>']
    table_rows = /#{f[0]}\d{1,2}.*?#{f[1]}\d{1,2}.*?#{f[2]}/

    raw_rows = page.scan table_rows
    raw_rows.each  do |r|
      row = Row.new
      row.parse_row(r)
      rows << row
    end
  end

# class Row
# Parse and store one row from the farn results table. Relevant sections begin
# with a <tt>tr</tt> column_name_ _data_ _n_, e.g. manuf_data_04.
# The headings for properties is stored in the containing FarnPageParser, not
# in the Row.
  class Row
# Manufacturer's part number.
    attr_reader :manufacturer_part_no

# Manufacturer's brand name.
    attr_reader :brand_name

# Description of this part, e.g. 'resistor, carbon comp'.
    attr_reader :description

# Extended properties for this part, e.g. resisitance, power rating.
    attr_reader :properties

# Link to Farn's page for this part.
    attr_reader :weblink

# Farn's order code for this part.
    attr_reader :supplier_part_no

# An array of QPrice to store the price-per-quantity for this part.
    attr_reader :prices

# Returns a new Row, properties and prices are empty arrays, other instance
# variables are set to 'empty'.
    def initialize
      @properties = []
      @prices = []
      @manufacturer_part_no = 'empty'
      @brand_name = 'empty'
      @description = 'empty'
      @weblink = 'empty'
      @supplier_part_no = 'empty'
    end

# Populates the instance variables b extracting information from each row.
    def parse_row(r)
      parse_manufacturer_data(r)
      parse_part_data(r)
      parse_description_data(r)
      parse_price_data(r)
      parse_parametrics_data(r)
    end

# Returns a string of all the information for this row.
# It does not include the property_headings, which are found in the
# containing FarnPageParser as this would result in a need to pass an argument
# to to_s, possibly go against convention.
    def to_s
      s = "Supplier part no: #{@supplier_part_no}" +
      "Manufacturer part no: #{@manufacturer_part_no}" +
      "Brand name: #{@brand_name}" +
      "Description: #{@description}" +
      "Suppliers web page: #{@weblink}" +
      'Properties: ' + @properties.join('; ') +
      'Prices: ' + @prices.join('; ')
      s
    end

# Returns a hash of all the information for this row. By passing the
# properties_headings from the containing FarnPageParser, the returned hash
# will include a hash of properties indexed by the relevant heading.
    def to_hash(prop_headings)
      h = {
        manufacturer_part_no: @manufacturer_part_no,
        supplier_part_no: @supplier_part_no,
        brand_name: @brand_name,
        description: @description,
        weblink: @weblink
      }
      h[:properties] = properties_to_hash_array(prop_headings)
      h[:prices] = prices_to_hash_array
      h
    end

    private

# Extracts @manufacturer_part_no.
    def parse_manufacturer_data(r)
      m = /manuf_data_\d{1,2}.*?<a.*?>(?'mpn'.*?)<\/a>/.match r
      @manufacturer_part_no = m[:mpn]
    end

# Extracts @weblink and @supplier_part_no
# Both are found within the same section.
    def parse_part_data(r)
      pattern = /part_data_\d{1,2}.*?<a.*?href="(?'link'.*?)">(?'spn'.*?)<\/a>/
      m = pattern.match r
      @weblink = m[:link]
      @supplier_part_no = m[:spn]
    end

# Extracts @description.
    def parse_description_data(r)
      f = ['description_data_', '<strong>', '</strong>', '</a>']
      pat =  /#{f[0]}\d{1,2}.*?#{f[1]}(?'bn'.*?)
              #{f[2]}.*?<a.*?>(?'desc'.*?)
              #{f[3]}/x

      m = pat.match r
      @brand_name = m[:bn]
      @description = m[:desc]
    end

# Extracts the @prices array.
    def parse_price_data(r)
      pattern = /PriceBreakFromContent.*?span>/
      price_data = r.scan pattern
      price_data.each do |p|
        qp = QPrice.new
        qp.parse(p)
        prices << qp
      end
    end

# Extracts the @properties array. Their term is parametrics data, hence the
# disparity between the method name and the attribute name.
    def parse_parametrics_data(r)
      pattern = /parametrics_data_\d{1,2}.*?>(.*?)<\/td>/
      props = r.scan pattern
      props.each { |p| @properties << p[0] }
    end

# Creates a hash array from the @properties array
    def properties_to_hash_array(prop_headings)
      hash_array = []
      @properties.each_with_index do |p, i|
        h = {}
        h[prop_headings[i]] = p.to_s
        hash_array << h
      end
      hash_array
    end

# Creates a hash from the @prices array
    def prices_to_hash_array
      prs = []
      prices.each { |p| prs << p.to_hash }
      prs
    end
  end # of class Row

# class QPrice
# stores a price-per-quantity for bulk orders.
  class QPrice
# Minimum order quantity for this price.
    attr_reader :quantity

# Pounds, an integer.
    attr_reader :pounds

# Pence, integer. It can be, and often is,  more than two figures.
    attr_reader :pence

# Sets @quantity, @pounds and @pence to zero.
    def initialize
      @quantity, @pounds, @pence = 0
    end

# Extracts @quantity and @pounds and @pence. It looks for quantities like 25+
# and prices like that begin with a Great British Pound Sign followed by a
# decimal number, denoting pounds and pence. Pence can be more than two
# decimal places.
    def parse(p)
      pattern = /(?'qty'\d{1,})\+.*?£(?'pounds'\d{1,})\.(?'pence'\d{1,})/
      m = pattern.match p
      @quantity = m[:qty].to_i
      @pounds = m[:pounds].to_i
      @pence = m[:pence].to_i
    end

# Returns an informative string of all its content.
    def to_s
      "Quantity: #{quantity}; Price: £#{pounds}.#{pence}"
    end

# Returns a hash to be used as part of a row's to_hash method.
    def to_hash
      { quantity: @quantity, pounds: @pounds, pence: @pence }
    end
  end
end
