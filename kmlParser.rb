#load accessory files
#make sure you're in the right directory when you run this 
# or it won't be able to find the file
require_relative 'indexConverter.rb'
#a purely original attempt

class Slide
  def addGeodata()
    require 'geocoder'
    coords=getCoordinates
    puts coords
    geodata=Geocoder.address(coords).split(",")
    if [@city,@region,@country]!=[0,0,0]
      puts "WARNING: Existing Geodata is being overwritten on slide #{getIndex}"
    end
    (@city,@region,@country)=[geodata[-5],geodata[-3],geodata[-1]]
  end
end
class String
  def hasDirection?()
    return (self.include?(" degrees") or self.include?(" up") or self.include?(" down"))
  end
end

############### M apping Functions ################################
# The first puts together the two main functions above into a simple mapping function
# the inputfile is a kml filename that has been downloaded from the google Mymaps.
# the resultfile can be any filename you like ending in .xls. If you don't pass a 
# resultfile, a (hopefully) unique one will be generated
# 
# To try an example, download UnitedKingdom.kml from the github and place it 
# in the same folder as this file. Then open a terminal and navigate to that 
# folder with the "cd" command. Once in the correct folder, the terminal should look like 
#
# C:\Users\SomeUser\aFolder\...\thisFolder> 
#
# Then type "irb" into the command line to start a ruby session.
#
# then type "load "kmlParser.rb"". If the terminal returns true, you are done.
# If it generates an error, you are probably not in the correct folder.
#
# Once the file is loaded, just call the mapping function below. For the sample file, that looks like
#
# mapKMLtoXLS("UnitedKingdom.kml")
#
# If this runs with no errors, there should be a new xls file containing the data in that folder.
#
# If an error is encountered, it is probably related to the syntax of the descriptions.
# The last output before the error should give you the slide number and title of the last one read.
def mapKMLtoXLS(inputfile,resultfile="blank",mode="CatNum")
  allinfo=stripInfo inputfile
  writeToXlsWithClass(allinfo, mode, resultfile)
end

def addSortingNumbers(inputfile,resultfile="blank",worksheet=0,columnNum=1)
  indexes=readXLScolumn(inputfile,worksheet,columnNum)
  sortingNumbers=generateSortingNumbers(indexes)
  writeXLSfromArray(resultfile,[sortingNumbers,indexes],["Sorting Number","Index"])
end
#filename="UnitedKingdom.kml"

#This function reads a kml file and returns a series of hashes containing all the 
# relevant information. It indexes each placemark by an integer, which is used as 
# a key for that info in each hash           
def stripInfo(kmlFilename)
  collectioninfo=Array.new

  titles=Hash.new
  descriptions=Hash.new
  locations=Hash.new
  lines=Hash.new

  #Determine which file to read
  filename=kmlFilename

#define control variables
  num=0
  header=false
  cordsread=false
  lineread=false
  linecords=Array.new
  doctitle="Title Field Blank"

#open file
  file=File.open(filename)

  index=0
  cordnum=0
#read file one line at a time (master loop)
  File.readlines(file).each do |line|
    #we begin by collecting all the important file and collection info and putting it into an array

    #Our first task is to collect the title of each entry
    #every title includes "<name>" and ends with "<\name>"
    if line.include? "<name>" and header==false
      endline=line.rindex "<"

      #titles including special characters have additional identifiers that must be removed 
      if line.include? "CDATA"
        splitline=line[21...endline-3]
 
      #the normal titles get cleaned here  
      else splitline=line[12...endline]
      end

      #items at the beginning and end of collections begin "(BXX)"
      #this also must be removed
      if splitline.include? "(B"
        splitline=splitline[6...]
      end
      title=splitline
      titles[index] = title
    end
    
    #we now collect the collection name. This will be the first element of the list we return
    if header==true
      start=line.index ">"
      start=start+1
      finish=line.rindex "<"
      doctitle=line[start...finish]
      header=false
    end 

    if line.include? "<Document>"
      header=true
    end

    #we begin with descriptions
    #search for our keyword
    if line.include? "<description>"
      endline=line.rindex "<"
      #split the line
      splitline=line[19...endline]
      activeDesc=splitline
      #reference our hashkeys list and create an entry in the descriptions hash
      descriptions[index]=activeDesc
    end

    #we then perform a simiilar process with the coordinates

  
    if cordsread==true
      cords=line[..-4]
      if lineread==false
        locations[index]=cords.lstrip!
        cordsread=false
      else
        if cordnum < 2
          linecords.push cords.lstrip!
          cordnum+=1
        else
          lines[index] = linecords
          cordsread=false
        end
      end 
    end

    if line.include? "<coordinates>"
      cordsread=true
      cordnum=0
    end
    
    if line.include? "<LineString>"
      lineread=true
      linecords=[]
    end

    #when we reach the end of an entry, we advance the index
    if line.include? "</Placemark>"
      if lineread
        lineread=false
      else 
        index=index+1
      end
      puts "Working, current index #{index}"
    end
  end
  file.close()
  return[doctitle,titles,descriptions,locations,lines]
end


#puts allinfo

=begin
for i in 1..allinfo[0].length

 if allinfo[1][allinfo[0][i]].class == String
  #puts "the "+i.to_s+"th description is a string" 
  puts "TITLE "+allinfo[0][i]+" HAS DESCRIPTION "+allinfo[1][allinfo[0][i]]
 end
end
=end 
def splitLocations (stringLocation)
  if stringLocation.class != String
    return ["there has been an error","like actually"]
  elsif (stringLocation.include? ",")==false
    return ["there has been an error","like actually"]
  else
    commaSpot=stringLocation.index ","
    latitude=stringLocation[...commaSpot]
    longitude=stringLocation[(commaSpot+1)..]
    return [longitude,latitude]
  end
end 


def writeToXlsWithClass(bigarray, mode="straight", filename="blank")
  #this function makes heavy use of the spreadsheet package. To install, type "gem install spreadsheet" into your terminal (windows)
  # or visit the source at https://rubygems.org/gems/spreadsheet/versions/1.3.0?locale=en
  require "spreadsheet" 
  #Next we set the encoding. This is the default setting but can be changed here
  Spreadsheet.client_encoding='UTF-8'
  
  #Now we define a mode. Each mode will direct the function to a different loop to produce different types of data.
  #"straight" mode keeps data organized by location, ex. Baly Cottage => B43.32-53,location
  #"CatNum" mode interprets each range and re-organizes it to read B43.32 => Baly Cottage, location



  #we now create our spreadsheet file
  book=Spreadsheet::Workbook.new
  mainsheet=book.create_worksheet
  
  #we then collect the title of the group and name our sheet after it
  collectionTitle=bigarray[0]
  mainsheet.name = collectionTitle

  #we define a disclaimer to populate the top left cell, identifying that it was produced by code
  disclaimer="This is an automatically generated spreadsheet titled \'#{collectionTitle}\' Please review the information before copying into permanent data storage."
  mainsheet[0,0] = disclaimer
  
  if mode=="straight"

    #then we make titles for each column
    mainsheet[1,0]="Title"
    mainsheet[1,1]="Description"
    mainsheet[1,2]="Longitude"
    mainsheet[1,3]="Latitude"

    #with our title and disclaimer made, we move into our main loop
    #the writing will take place one row at a time, and will be based on the list of keys (bigarray[1])

    bigarray.length.times do |i|
      #gather info
      index=i
      title = bigarray[1][index]
      description=bigarray[2][index]
      location=bigarray[3][index]
      
      #while most of the data is ready to input, the locations are still a string tuple.
      #we must split this into its parts before entry

      locationTuple = splitLocations location

      #populate info
      mainsheet[i+2,0]=title
      mainsheet[i+2,1]=description
      mainsheet[i+2,2]=locationTuple[0]
      mainsheet[i+2,3]=locationTuple[1]
    end 
  end

  if mode == "CatNum"
    seenSlides=Hash.new
    bigarray[1].length.times do |index|
      title= bigarray[1][index]
      desc = bigarray[2][index]
      if desc.class != NilClass
        location=bigarray[3][index]
        locationTuple=splitLocations location 
        slidesarray = parseSlideRange(desc)[0]
        puts slidesarray
        slidesarray.each do |cat|
          if cat.class == NilClass
            print "The slide with categorization #{cat} and title #{title} (#{index}) could not be parsed, and has been skipped"
          elsif cat.include? "ERROR"
            print "The slide with categorization #{cat} and title #{title} (#{index}) could not be parsed, and has been skipped"
          else
            #puts seenSlides
            puts index
            puts cat
            if seenSlides.include? cat
              slide=seenSlides[cat]
              addLocationToSlide(slide,locationTuple,title,desc)
            else  
              slide=Slide.new(cat)
              addLocationToSlide(slide,locationTuple,title,desc)
              altId=indexConverter(slide.getindex)
              if altId.class == Classification
                slide.addAltID(altId)
              end
              seenSlides[cat]=slide
            end
          end
        end
      end
    end
    lastblock=2
    #populate spreadsheet
    formatspreadsheet(mainsheet)
    slides=seenSlides.values.sort_by {|slide| slide.getindex.to_s}
    slides.each do |slide|
      #slide.addGeodata
      slideData=formatSlideData(slide)
      for i in [0..slideData.length]
        mainsheet[lastblock,i]=slideData[i]
      end
      lastblock+=1
    end
  end
  if filename != "blank"
    book.write filename
  else 
    book.write generateUniqueFilename("xls",collectionTitle)
  end
end


def addLocationToSlide(slide,locationTuple,title,desc)
  puts "Description: #{desc}"
  data=stripData(desc)
  if data.class != Array
    notes=data
    slide.addLocation([locationTuple,title,notes],false,false)
  elsif data[0].class != NilClass
    slide.addLocation([locationTuple,data[0],data[1],title],true,false)
  end
  
end
  
def stripData(desc)
  if desc.hasDirection? == false
    lastnum=-1
    if desc.include? ". "
      sentences=desc.split(". ")[1..]
      notes=''
      if sentences.length > 1
        sentences.each do |item|
          notes+=item
        end
      else
        notes=sentences[0]
      end
    else
      desc.each_char do |char|
        if char.is_integer?
          lastnum=desc.rindex char
        end
      end
      notes=desc[lastnum+1..]
    end
    return notes
  else
    firstspace=desc.index " "
    while firstspace <= 1
      firstspace=firstspace+desc[firstspace..].index(" ")
    end
    sentences=desc[firstspace..].split ". "
    angledata=sentences[0]
    if sentences.length > 1
      notes=''
      sentences[1..].each do |sentence|
        notes += sentence
      end
      return [angledata,notes]
    end
    return [angledata,0 ]
  end
end

def formatspreadsheet(sheet)
  fields=["Slide Title","Baly Cat","VRC Cat","General Place Name","General Coordinates","Specific Coordinates","Direction","Precision","Notes","City","Region","Country"]
  for i in [0..fields.length]
    sheet[1,i]=fields[i]
#    format=Spreadsheet::Format.new :width => fields[i].length
#    sheet.col(i).default_format=format
  end
end
def formatSlideData(slide)
  balyid=slide.getindex("Baly").to_s
  vrcid=slide.getindex("VRC").to_s
  generalLoc=slide.generalLocation
  if generalLoc != 0
    locationName= generalLoc.name
    genCoords = formatCoords(generalLoc.coords)
  else
    locationName=""
    genCoords = ["",""]
  end
  specificLoc=slide.specificLocation
  if specificLoc!=0
    title=specificLoc.title
    specCoords = formatCoords(specificLoc.coords)
    specAngle=specificLoc.angle.to_s
    precision=specificLoc.precision
  else
    title=""
    specCoords=["",""]
    specAngle=""
  end
  resultarray=[title,balyid,vrcid,locationName,genCoords,specCoords,specAngle,precision]
  notes=""
  [generalLoc,specificLoc].each do |loc|
    if loc.class < Location
      eachnote=loc.notes
      if eachnote != 0
        notes += eachnote
      end
    end
  end
  resultarray.push notes
  resultarray+=slide.getGeodata
  resultarray.each do |element|
    if element == 0
      element=""
    end
  end
  return resultarray
end
def formatCoords(coordinateArray)
  latitude=coordinateArray[0]
  longitude=coordinateArray[1]
  return "(#{latitude},#{longitude})"
end
def writeToXls(bigarray, mode="straight", filename="blank")
  #this function makes heavy use of the spreadsheet package. To install, type "gem install spreadsheet" into your terminal (windows)
  # or visit the source at https://rubygems.org/gems/spreadsheet/versions/1.3.0?locale=en
  require "spreadsheet" 
  #Next we set the encoding. This is the default setting but can be changed here
  Spreadsheet.client_encoding='UTF-8'
  
  #Now we define a mode. Each mode will direct the function to a different loop to produce different types of data.
  #"straight" mode keeps data organized by location, ex. Baly Cottage => B43.32-53,location
  #"CatNum" mode interprets each range and re-organizes it to read B43.32 => Baly Cottage, location



  #we now create our spreadsheet file
  book=Spreadsheet::Workbook.new
  mainsheet=book.create_worksheet
  
  #we then collect the title of the group and name our sheet after it
  collectionTitle=bigarray[0]
  mainsheet.name = collectionTitle

  #we define a disclaimer to populate the top left cell, identifying that it was produced by code
  disclaimer="This is an automatically generated spreadsheet titled \'" + collectionTitle + ".\' Please review the information before copying into permanent data storage."
  mainsheet[0,0] = disclaimer
  
  if mode=="straight"

    #then we make titles for each column
    mainsheet[1,0]="Title"
    mainsheet[1,1]="Description"
    mainsheet[1,2]="Longitude"
    mainsheet[1,3]="Latitude"

    #with our title and disclaimer made, we move into our main loop
    #the writing will take place one row at a time, and will be based on the list of keys (bigarray[1])

    for i in 2..bigarray[1].length
      #gather info
      title = bigarray[1][i]
      description=bigarray[2][title]
      location=bigarray[3][title]
    
      #while most of the data is ready to input, the locations are still a string tuple.
      #we must split this into its parts before entry

      locationTuple = splitLocations location

      #populate info
      mainsheet[i,0]=title
      mainsheet[i,1]=description
      mainsheet[i,2]=locationTuple[0]
      mainsheet[i,3]=locationTuple[1]
    end 
  end

  if mode == "CatNum"
    titlesToMentions=Hash.new
    upperslides=Array.new
    lowerslides=Array.new
    for i in 0...bigarray[1].length
      activetitle=bigarray[1][i]
      desc = bigarray[2][activetitle]
      puts desc
      
      if desc.class != NilClass

        if desc.include? "-"
          smallerarray = parseSlideRange desc
          lowerslides.push smallerarray[1]
          upperslides.push smallerarray[2]
          titlesToMentions[activetitle]=smallerarray[0]
        elsif desc.length > 5
          slide=desc[..6]
          lowerslides.push slide
          upperslides.push slide
          titlesToMentions[activetitle]=[slide]
        end
      end
    end
    lastblock=2

    #populate spreadsheet
    mainsheet[1,0]="Cat#"
    mainsheet[1,1]="Slide Title"
    mainsheet[1,2]="Longitude"
    mainsheet[1,3]="Latitude"

    for i in 0...bigarray[1].length
      activetitle=bigarray[1][i]
      workinglist=titlesToMentions[activetitle]
      location=bigarray[3][activetitle]
      locationTuple=splitLocations location
      if workinglist.class != NilClass
        for j in 0...workinglist.length
          mainsheet[lastblock,0]=workinglist[j]
          mainsheet[lastblock,1]=activetitle
          mainsheet[lastblock,2]=locationTuple[0]
          mainsheet[lastblock,3]=locationTuple[1]
          lastblock=lastblock+1
        end
      end
    end
  end


  if filename != "blank"
    book.write filename
  else 
    time=Time.now
    minutes=time.min
    seconds=time.sec

    book.write collectionTitle+minutes.to_s + "." + seconds.to_s+".xls"
  end
end

#This function reads an xlsfile and turns one column into an array. 
#Its inputs are a string of the file to read, and two integer indexes for the worksheet and column.
def readXLScolumn(xlsfile,worksheet,columnNum)
  require 'spreadsheet'
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet.open xlsfile
  sheet=book.worksheet worksheet
  
  indexarray=Array.new
  sheet.each do |row|
    eachindex=row[columnNum]
    indexarray.push eachindex
  end
  return indexarray
end
#puts parseSlideRange "B45.321 approximate location at 35 degrees N"
#"B27.012-15, B47.654-63, 716-18,B45.9-10, B45.63-67. WHat the"

#then we take that input and write it to a newfile. 
#These inputs are a string filename, an Array of Arrays representing each column to write,
# plus an optional array input containing the headers
def writeXLSfromArray(newfile,data,headers=[])
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet::Workbook.new
  sheet = book.create_worksheet
  if headers != []
    sheet[0,0..headers.length]=headers
    rowtostart=1
  else
    rowtostart=0
  end
  currentcol=0
  data.each do |colArray|
    currentrow=rowtostart
    colArray.each do |item|
      sheet[currentrow,currentcol]=item
      currentrow+=1
    end
    currentcol+=1
  end

  if newfile[-3..] != "xls"
    newfile=generateUniqueFilename("xls","NewSpreadsheet")
  end
  book.write newfile
end
=begin testing
A sample input
writeXLSfromArray("test.xls",[["col1","r1","r2","r3","r4","r5"],["col2",1,2,3,4,5]],["sampleHeader1","sampleheader2"])
=end