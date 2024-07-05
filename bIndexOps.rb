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

class InputError < StandardError
end
#First a hash of metadata fields and how to find them in the spreadsheet.
#Dates, old numbers, and keywords are fixed since they require parsing. 
#Fields listed below are pulled from the spreadsheet with no modification.
MetaFields={"locations"=> [{"title"=>"General Location Name",
                            "type"=>"=general",
                            "coordinates"=>"General Coordinates"
                          },
                          {"type" => "=object",
                            "latitude" => "Object Latitude",
                            "longitude" => "Object Longitude"
                          },
                          {"title"=>"Specific Location Name",
                            "type"=>"=specific",
                            "coordinates" => "Specific Coordinates",
                            "precision" => "Precision",
                            "angle" => "Direction"}
                         ],
            "notes" => {"slide_notes" => "written on the slide",
                        "index_notes" => "written on the Baly index"}
}
SampleRowHash={"Image ID"=>"A.002","Written Date"=>"June 1970",
"Printed Date"=>"JUL 70N","old identification numbers"=>"A.19,A.22,A.04",
"Keywords"=>"Dome of the Rock, Temple Mount, Haram al-Sharif, Holy Esplanade, Old City of Jerusalem, Jerusalem",
"General Location Name"=>"Dome of the Rock","General Coordinates"=>"(31.7779279,35.2352684)",
"Specific Location Name"=>"Dome of the Rock Through Western Arch","Specific Coordinates"=>"(31.7778467,35.2346017)",
"Precision"=>"likely","Direction"=>"70 degrees E","Object Latitude"=>"35.2354 E","Object Longitude"=>"31.7780 N",
"written on the slide"=>"Isfahan, Friday Mosque ","written on Baly Index"=>"Friday Mosque "
}                
def fillJSON(indexfile,overwrite=true)
  #we begin by collecting all of the endpoints we will need
  sheetfields=["Written Date","Printed Date","old identification numbers","Keywords"]
  overfillerror=InputError.new "metadata nesting exceeded 3 levels and could not be parsed. Check MetaFields hash in bIndexOps.rb"
  addedFields=parseNestedEndpoints(MetaFields,overfillerror)
  finalfields=["Image ID"]+sheetfields+addedFields+["JSON"]
  data=readIndexData(indexfile,0,finalfields,"Hash")
  newdata=Array.new
  data.each do |row|
    newrow=row.values
    if row[-1].to_s.length < 3 and overwrite==false
      json=row[-1]
    else
      json=writeJSON(row)
    end
    newrow[-1]=json
    newdata.push newrow
  end
  newfilename=generateUniqueFilename("xls","JSONAdded")
  writeXLSfromRowArray(newfilename,newdata[1..],finalfields)
end

def writeJSON(rowHash)
  require 'json'
  required=generateReqHash(rowHash)
  optional=generateOptHash(rowHash)
  assembled=required.merge optional
  return JSON.generate assembled
end

def generateOptHash(rowHash)
  optHash=Hash.new
  MetaFields.each do |bigkey,value|
    if value.class == Array
      optHash[bigkey]=Array.new
      value.each do |value2|
        if value2.class == Array
          vals2=Array.new
          value2.each do |value3|
            if fillable?(value3)
              aahResult = fillHashfromRow(value3,rowHash)
              vals2.push aahResult
            end
          end
          optHash[bigkey].push vals2
        elsif value2.class == Hash
          unless fillable?(value2)
            hvals2=Hash.new
            value2.each do |smkey,value3|
              if fillable?(value3)
                ahhResult=fillHashfromRow(value3,rowHash)
                hvals2[smkey]=ahhResult
              end
            end
            optHash[bigkey].push hvals2
          else
            ahResult=fillHashfromRow(value2,rowHash)
            optHash[bigkey].push ahResult
          end
        end
      end
    elsif value.class==Hash
      unless fillable?(value)
        hvals=Hash.new
        value.each do |key,value2|
          if value2.class == Array
            vals2=Array.new
            value2.each do |value3|
              if fillable?(value3)
                hahResult = fillHashfromRow(value3,rowHash)
                vals2.push hahResult
              end
            end
            hvals[key] = vals2
          elsif value2.class == Hash
            unless fillable?(value2)
              hvals2=Hash.new
              value2.each do |smkey,value3|
                if fillable?(value3)
                  hhhResult=fillHashfromRow(value3,rowHash)
                  hvals2[smkey]=hhhResult
                end
              end
              hvals[key]=hvals2
            else
              hhResult=fillHashfromRow(value2,rowHash)
              hvals[key]=hhResult
            end
            optHash[bigkey]=hvals
          end
        end
      else
        hResult=fillHashfromRow(value,rowHash)
        optHash[bigkey]=hResult
      end
    end
  end
  return optHash
end

def fillable?(item)
  return (item.class==Hash and item.values[0].class == String)
end

def fillHashfromRow(structure,rowHash)
  filled=Hash.new
  structure.each do |key,value|
    if value[0]=="="
      filled[key]=value[1..]
    elsif rowHash[value].class == String
      puts rowHash[value].class
      filled[key]=rowHash[value]
    else
      filled[key]="-"
    end
  end
  return filled
end
def generateReqHash(rowHash)
  reqHash=Hash.new
  writtenDate=parseWrittenDates(rowHash["Written Date"].to_s,"Array")
  printedDate=parsePrintedDates(rowHash["Printed Date"].to_s,"Array")
  topkey="dates"
  writeHash = {"type"=>"written",
               "day"=>"#{writtenDate[0]}",
               "month"=>"#{writtenDate[1]}",
               "year"=>"#{writtenDate[2]}"}
  printHash={"type"=>"printed",
             "month"=>"#{printedDate[0]}",
             "year"=>"#{printedDate[1]}"}
  reqHash[topkey]=[writeHash,printHash]

  oldIds=rowHash["old identification numbers"].split(",")
  reqHash["old_ids"]=oldIds

  keywords=rowHash["Keywords"].split(",")
  reqHash["Keywords"]=keywords
  return reqHash
end
#THIS NEEDS TO BE WELL TESTED SOON
#a function that will parse a complex (up to three levels) hash of nested data
#and return all the final endpoints
def parseNestedEndpoints(nest, errormsg)
  fieldsarray=Array.new
  nest.each do |bigkey,value|
    if value.class==Array
      value.each do |value2|
        if value2.class==Array
          value2.each do |value3|
            unless value3.class == Hash
              raise errormsg
            else
              value3.each do |lilkey,value4|
                if value4.class == String and value4[0] != "="
                  fieldsarray.push value4
                elsif value4[0] != "="
                  raise overfillerror        
                end
              end
            end
          end
        elsif value2.class == Hash
          value2.each do |key,value3|
            if value3.class == Hash
              value3.each do |key,value4|
                if value4.class==String and value4[0] != "="
                  fieldsarray.push value4
                elsif value4[0] != "="
                  raise errormsg
                end
              end
            elsif value3.class == String and value3[0] != "="
              fieldsarray.push value3
            elsif value3[0] != "="
              raise errormsg
            end
          end
        elsif value2.class==String and value2[0] != "="
          fieldsarray.push value2
        end
      end
    elsif value.class == Hash
      value.each do |key,value2|
        if value2.class==Array
          value2.each do |value3|
            unless value3.class == Hash
              raise errormsg
            else
              value3.each do |lilkey,value4|
                if value4.class == String and value4[0] != "="
                  fieldsarray.push value4
                elsif value4[0] != "="
                  raise errormsg
                end
              end
            end
          end
        elsif value2.class == Hash
          value2.each do |key,value3|
            if value3.class == Hash
              value3.each do |key,value4|
                if value4.class==String and value4[0] != "="
                  fieldsarray.push value4
                elsif value4[0] != "="
                  raise errormsg
                end
              end
            elsif value3.class == String and value3[0] != "="
              fieldsarray.push value3
            elsif value3[0] != "="
              raise errormsg
            end
          end
        elsif value2.class==String and value2[0] != "="
          fieldsarray.push value2
        end
      end
    elsif value.class == String and value[0] != "="
      fieldsarray.push value
    end
  end
  return fieldsarray
end
                

def fillImageNotes(indexfile,overwrite=false)
  fields=["Image ID","Written Date","Printed Date","VRC slide number","old identification numbers","Words written on the slide","Words written on the Baly index","Image Notes"]
  data=readIndexData(indexfile,0,fields,"Array")
  newdata=Array.new
  data.each do |row|
    newrow=row[..-1]
    if row[-1].to_s.length > 3 and overwrite == false
      imNotes=row[-1]
    else
      imNotes=writeImageNotes(row[1],row[2],row[3],row[4],row[5],row[6])
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

def writeImageNotes(writtenDate,printedDate,vrcNum,oldNums,slideWords,indexWords)
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
  if vrcNum.length > 3 or oldNums.length > 2
    if vrcNum.length > 3
      vrcCat=Classification.new(vrcNum)
      vrcstring=vrcCat.to_s
    else
      vrcstring=""
    end
    cleanNums=""
    oldNums.split(",").each do |num|
      begin
        oldcat=Classification.new(num.fullstrip)
        cleanNums+=", "+oldcat.to_s
      end
    end
    assembledNums=vrcstring+cleanNums
    if assembledNums[0] == ","
      assembledNums=assembledNums[2..]
    end
    altIdSentence="Formerly catalogued as #{assembledNums}. "
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
def parseWrittenDates(stringin, mode="String")
  #we check if the date is just the year, if it is we return it.
  if stringin.fullstrip.is_integer?
    return stringin.fullstrip
  end
  begin
    date=Date.parse(stringin)
  rescue
    puts "Date #{stringin} could not be parsed. Fix syntax or update parseWrittenDates"
    if mode == "String"
      return "-"
    elsif mode == "Array"
      return ["-","-","-"]
    end
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
  if mode=="String"
    if day == 0
      return month+" "+year.to_s
    else
      return month+" "+day+", "+year.to_s
    end
  elsif mode=="Array"
    if day == 0
      return ["-",month,year]
    else
      return [day,month,year]
    end
  end
end

def parsePrintedDates(stringin,mode="String")
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
  if mode=="String"
    return Months[date.month-1]+" "+year.to_s
  elsif mode == "Array"
    return [Months[date.month-1],year]
  end
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