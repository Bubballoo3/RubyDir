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

def fillImageNotes(indexfile,overwrite=false)
  fields=["Image ID","Written Date","Printed Date","VRC slide number","Words written on the slide","Words written on the Baly index","Image Notes"]
  data=readIndexData(indexfile,0,fields,"Array")
  newdata=Array.new
  data.each do |row|
    newrow=row[..-1]
    if row[-1].length > 3 and overwrite == false
      imNotes=row[-1]
    else
      imNotes=writeImageNotes(row[1],row[2],row[3],row[4],row[5])
    end
    newrow[-1]=imNotes
    newdata.push newrow
  end
  newfilename=generateUniqueFilename("xls","ImageNotesAdded")
  writeXLSfromRowArray(newfilename,newdata[1..],fields)
end

def readIndexData(indexfile,worksheet=0,fields=DefaultFields,rowform="Hash")
  require 'spreadsheet'
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet.open indexfile
  sheet=book.worksheet worksheet
  fieldLocs=getFieldLocs(sheet.row(0),fields)
  sheetData=Array.new
  sheet.each do |row|
    rowdataHash=Hash.new
    rowdataList=Array.new
    fieldLocs.each do |key,value|
      data=row[value]
      if data.class == NilClass
        data=""
      end
      if rowform.downcase == "hash"
        rowdataHash[key]=data.to_s
      else
        rowdataList.push data.to_s
      end
    end
    unless rowdataList.length > 0
      sheetData.push rowdataHash
    else
      sheetData.push rowdataList
    end
  end
  return sheetData
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

def writeImageNotes(writtenDate,printedDate,vrcNum,slideWords,indexWords)
  if writtenDate.length > 1
    creationDate=parseWrittenDates writtenDate
    creationSentence="Photograph created #{creationDate}. "
  else
    creationSentence="Creation date unknown. "
  end
  if printedDate.length > 4
    printingDate=parsePrintedDates printedDate
    printingSentence="Photograph processed #{printingDate}. "
  else
    printingSentence="Processing date unknown. "
  end
  if vrcNum.length > 3
    vrcCat=Classification.new(vrcNum)
    altIdSentence="Formerly catalogued as #{vrcCat.to_s}. "
  else
    altIdSentence=""
  end
  if slideWords.length > 3
    slideWriting=slideWords.fullstrip
  else
    slideWriting=""
  end
  if indexWords.length > 3
    indexWriting=indexWords.fullstrip
  else
    indexWriting=""
  end
  writingSentence="Notes written on the slide or index: #{slideWriting}, #{indexWriting}."
  return creationSentence+printingSentence+altIdSentence+writingSentence
end

Months=["January","February","March","April","May","June","July","August","September","October","November","December"]
#This function parses the "Written Dates" section of the index, converting an abbreviated or partial date to an acceptable string.
def parseWrittenDates(stringin)
  #we check if the date is just the year, if it is we return it.
  if stringin.fullstrip.is_integer?
    return stringin.fullstrip
  end
  begin
    date=Date.parse(stringin)
  rescue
    puts "Date #{stringin} could not be parsed. Fix syntax or update parseWrittenDates"
    return "-"
  end
  month=Months[date.month-1]
  daynum=date.day
  if daynum == 1
    if stringin.include?(" 1,") or stringin.include?(" 1 ")
      day="1st"
    else
      day=0
    end
  elsif daynum == 2
    day="2nd"
  elsif daynum == 3
    day="3rd"
  else
    day=daynum.to_s+"th"
  end
  year=date.year
  if year > 2000
    year=year-100
  end
  if day == 0
    return month+" "+year.to_s
  else
    return month+" "+day+", "+year.to_s
  end
end

def parsePrintedDates(stringin)
  input=stringin.fullstrip
  if input=="-" or input == ""
    return "-"
  end
  begin
    date=Date.parse(stringin)
  rescue
    halves=input.split " "
    if halves[0].fullstrip == "ENE"
      monthin="JAN"
    else
      monthin=halves[0]
    end
    yearin=halves[1][..1]
    date=Date.parse(monthin+" \'"+yearin)
  end
  year=date.year
  if year > 2000
    year=year-100
  end
  return Months[date.month-1]+" "+year.to_s
end

def writeXLSfromRowArray(newfile,data,headers=[])
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet::Workbook.new
  sheet = book.create_worksheet
  if headers != []
    sheet[0,0..headers.length]=headers
    rowtostart=1
  else
    rowtostart=0
  end
  currentrow=rowtostart
  data.each do |rowArray|
    sheet[currentrow,..-1]=rowArray
    currentrow+=1
  end
  if newfile[-3..] != "xls"
    newfile=generateUniqueFilename("xls","NewSpreadsheet")
  end
  book.write newfile
end