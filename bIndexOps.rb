# This is a collection of operations to be used on the full Baly Index

#load necessary files
require_relative 'kmlParser.rb'

DefaultFields=["Title","Image ID","Written Date","Printed Date","VRC slide number","References",
"Other old identification numbers","Words written on the slide","Words written on the Baly index",
"Image Notes","Creation Year","Subcollection","City","Country","Region","latitude","longitude",
"Direction","Keywords","Re-scan","Frame # do not  record","URL"]

class Slide
  #we add a generic attribute adder that will identify the correct function to use.
  def addAttribute(attr,data)
  
  end
end

def readIndexData(indexfile,worksheet=0,fields=DefaultFields)
  require 'spreadsheet'
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet.open indexfile
  sheet=book.worksheet worksheet
  fieldLocs=getFieldLocs(sheet.row(0),fields)
  sheet.each do |row|
    fieldLocs.each do |key|
    end
  end
end

def getFieldLocs(headerRow,fields)
  rtnHash=Hash.new
  fields.each do |f|
    indexes=headerRow.includesAtIndex(f)
    puts indexes
    if indexes.length == 1
      index=indexes[0]
    elsif indexes.length > 1
      print "Warning: field #{f} has been found in multiple places. The first occurrence has been used."
      index=indexes[0]
    else
      raise StandardError.new("The field \'#{f}\' could not be found in the first row of the sheet. Check field names and worksheet number.")
    end
    rtnHash[f]=index
  end
  if fields.length != rtnHash.length
    print "Warning: Not all the fields have been included"
  else 
    return rtnHash
  end     
end



def getLocationAttributes(coordinateArray)
  require 'geocoder'
  stAdd=Geocoder.address(coordinateArray)
  attrs=stAdd.split(',')
  citycountry=[attrs[-5],attrs[-1]]
  return citycountry
end