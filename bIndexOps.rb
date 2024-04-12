# This is a collection of operations to be used on the full Baly Index

#load necessary files
require_relative 'kmlParser.rb'

DefaultFields=["Title","Image ID","Written Date","Printed Date","VRC slide number","References",
"Other old identification numbers","Words written on the slide","Words written on the Baly index",
"Image Notes","Creation Year","Subcollection","City","Country","Region","latitude","longitude",
"Direction","Keywords","Re-scan","Image Notes","Frame # do not  record","URL"]

def readIndexData(indexfile,worksheet=0,fields=DefaultFields)
  require 'spreadsheet'
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet.open indexfile
  sheet=book.worksheet worksheet
  fieldLocs=getFieldLocs(sheet.row(0),fields)
  
end

def getFieldLocs(headerRow,fields)
  rtnHash=Hash.new
  fields.each do |f|
    index=0
    correctIndex=-1

    headerRow.each do |i|
      if i.include? f
        correctIndex=index
      end
      index+=1
    end

    if index == -1
      raise StandardError.new("The field \'#{f}\' could not be found in the first row of the sheet. Check field names and worksheet number.")
    else
      rtnHash[f]=index
    end
  end
  if fields.length != rtnHash.length
    print "Warning: Not all the fields have been included"
  else 
    return rtnHash
  end     
end
