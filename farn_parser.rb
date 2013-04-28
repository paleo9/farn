#! /usr/bin/ruby
#encoding: UTF-8

require './helpers'

class Part
  attr_accessor :order_code, :pdf, :prices, :web, :manufacturer_code, :extended_properties
  def initialize
    @order_code = ""
    @pdf = ""
    @prices = []
    @extended_properties = []
  end
  def prices_to_s
    return "[" + to_csv(@prices) + "]"
  end
  def extended_properties_to_s
    return "[" + to_csv(@extended_properties) + "]"
  end
  def to_s
    s = to_csv([
      @order_code, 
      @manufacturer_code, 
      @web, 
      @pdf]) + 
      ", " +  
      prices_to_s + 
      extended_properties_to_s
      return s
  end
end

class Farn_parser
  attr_accessor :part_name, :original_query, :headings, :parts


  def initialize(infile)
    #### read file  ####
    fin = File.open(infile, 'r')
    @line = fin.read
    @line.tr!("\n","")
    fin.close
    
    #### headings ####
    @headings = ["Order Code", "Manufacturer Code", "Web", "PDF", "Prices"]

    ## These need to only match once ##
    
    #### part name ####
    m = @line.match /<h1.*?>(.*?):/
    @part_name = $1

     # original query ####
    m = @line.match /(originalQueryURL=.*?)"/
    @original_query = $1
    
    ## This needs to match once,     ##
    ## but it's made from many items ##
    #### extended headings ####
    m = @line.scan /resultsHead1">(.*?)<\/th>/
    m.each{ |s|
      @headings.push s[0]
    }

     #### parts array ####
     @parts = Array.new(25) {Part.new}

     ## These need to match for each part ##

     #### pdf ####
    m = @line.scan /heading-image_data_(\d+).*?techInfo.*?href="(.*?)"/
    m.each{ |s|
      @parts[s[0].to_i].pdf = s[1]
    }

    #### order code ####
    m = @line.scan /<td.*?heading-part_data_(\d+).*?<a href=".*?">(.*?)<\/a>/
    m.each{ |s|
      @parts[s[0].to_i].order_code = s[1]
    }

    #### web link ####
    m = @line.scan /<td.*?heading-part_data_(\d+).*?<a href="(.*?)">.*?<\/a>/ 
    m.each{ |s|
      @parts[s[0].to_i].web = s[1]
    }

    #### manufacturer code ####
    m = @line.scan /heading-manuf_data_(\d+).*?><a href=".*?">(.*?)<\/a>/
    m.each{ |s|
      @parts[s[0].to_i].manufacturer_code = s[1]
    }

    # These need to match each part, and are made from many items

    #### prices ####
    m = @line.scan /(heading-list-price_data_(\d+).*?results\.column-heading)/
    m.each{ |s|
      p = s[0].scan /(\d+\+).*?(£\d+\.\d{2})/
      p.each{ |q|
        @parts[s[1].to_i].prices.push (q[0] + " " + q[1])
      }
    }

    ## extended properties
    m = @line.scan /heading-parametrics_data_(\d+).*?>(.*?)<\/td>/
    m.each{ |s|
        @parts[s[0].to_i].extended_properties.push(s[1])
      }
  end # of initialize
  
  def headings_to_s
    return "[" + to_csv(@headings) + "]"
  end

  def to_s
    s = @part_name + "\n" +
        @original_query + "\n" +
        headings_to_s + "\n\n"
        @parts.each{ |p|
            s += p.to_s + "\n\n"
        }
    return s
  end

  def to_file(outfile)
    fout = File.open(outfile, 'w')
    fout.write to_s
    fout.close
  end

end

