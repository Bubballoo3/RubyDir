=begin
This is a test document for Ruby explorations
---------------------------------------------
Include notes and advice in this section
----------------------------------------
=end

=begin
#This is an attempt to parse kml files into hashs for each item

file=File.open("UnitedKingdom.kml")

text=file.read
=end

#This is a github script found at https://gist.github.com/eliotk/7744806 that has been modified to interpret a single file from Google MyMaps.
=begin
require 'nokogiri'
require 'csv'

kml_path = '/path/to/Google Drive/My Tracks/'

#def kml_file_paths path
#  Dir.glob(path + "*.kml")
#end

csv = CSV.open('mytracks.csv', "wb")

#kml_file_paths(kml_path).each_with_index do |file_path, index|
file_path="UnitedKingdom.kml"
kml = File.read(file_path)
doc = Nokogiri::XML(kml)
  
  # summary data is stored as cdata in the last Placemark entity's description child node
desc_lines = doc.search('description').text.split(/\n/)
desc_lines.each do |reading|
  puts reading[1]
  puts "counting : #{reading.count("")}\n\n"
  puts "THAT WAS THE END OF THE DESCRIPTION"
 end
=end

#a purely original attempt

#some initial data

#this array contains all the keywords marking values we want to store. This uses the same strings used in the kml file.

filename="UnitedKingdom.kml"


                       
def stripInfo(kmlFilename)
  collectioninfo=Array.new

  hashkeys=Array.new

  descriptions=Hash.new

  locations=Hash.new

  #Determine which file to read
  filename=kmlFilename

#define control variables
  num=0
  header=false
  cordsread=false
  doctitle="Title Field Blank"

#open file
  file=File.open(filename)


#read file one line at a time (master loop)
  File.readlines(file).each do |line|
    #we begin by collecting all the important file and collection info and putting it into an array


    #Our next task is to collect the title of each entry
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
      hashkeys.push title
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
      #with our titles collected, we connect them to descriptions and locations using hashes

    #we begin with descriptions
    #search for our keyword
    if line.include? "<description>"
      endline=line.rindex "<"
      #split the line
      splitline=line[19...endline]
      activeDesc=splitline
      #reference our hashkeys list and create an entry in the descriptions hash
      descriptions[hashkeys[-1]]=activeDesc
    end

    #we then perform a simiilar process with the coordinates

  
    if cordsread==true
      cords=line[..-4]
      locations[hashkeys[-1]]=cords.lstrip!
      cordsread=false
    end

    if line.include? "<coordinates>"
      cordsread=true
    end
  end
  file.close()
  return[doctitle,hashkeys,descriptions,locations]
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
    longitude=stringLocation[...commaSpot]
    latitude=stringLocation[(commaSpot+1)..]
    return [longitude,latitude]
  end
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

def parseSlideRange(string)
  #this will be our array that we return at the end
  slidesMentioned=Array.new

  collectionsMentioned=Array.new
  collectionsToIndex=Hash.new

  #we begin by splitting the ranges. 
  #Ranges are separated by commas, and common info is not repeated
  #an especially complicated example of this is 
  #"B27.012-15, B45.905-06, B47.654-63, 716-18"
  if string.include? ". "
      n=string.index ". "
      string=string[...n]
  end

  ranges=string.split(",",-1)
  
  for i in 0...ranges.length
      ranges[i] = ranges[i].lstrip
  end
  #next we store each B-collection in case the next one reuses it
  lastcollection="ERROR"

  #we now loop through the ranges and process them
  for i in 0...ranges.length
    range=ranges[i]
    
    #the following will be a sample range to indicate which parts the code is handling
    
    #B22.222-22  
    #   ^
    if range.include? "."
      decimalpoint=range.index "."
      nextpoint=decimalpoint+1
      rightside=range[nextpoint..]
    else
      #in case it is only 222-22 
      decimalpoint=0
      rightside=range
    end
    
    #B22.222-22
    #^^^

    if range[0]=="B"
      lastcollection=range[...decimalpoint]
      unless collectionsMentioned.include? lastcollection
        collectionsMentioned.push lastcollection
      end 
    end
    
    #B22.222-22
    #       ^
    if rightside.include? "-"
      dashplace=rightside.index "-"
    
      if dashplace < 3
        rightside="0" + rightside
        if dashplace < 2
          rightside="0"+rightside
        end
      end
      dashplace=4
      hundreds=rightside[0]
      start=rightside[1..2].to_i
      last=rightside[dashplace..].to_i
      for i in start..last
        slidestem=lastcollection + "." + hundreds
        if i.to_s.length < 2
          ending="0"+i.to_s
        else 
          ending=i.to_s
        end
        slide=slidestem+ending
        slidesMentioned.push slide
      end
    else 
      slide=lastcollection+"."+rightside
      slidesMentioned.push slide
    end
  end

  slidesMentioned=slidesMentioned.sort
  minslide=slidesMentioned[0]
  maxslide=slidesMentioned[-1]
  return [slidesMentioned,minslide,maxslide]
  #we begin by splitting our description up by subcollection. 
end 
#puts parseSlideRange "B45.321 approximate location at 35 degrees N"
#"B27.012-15, B47.654-63, 716-18,B45.9-10, B45.63-67. WHat the"

def indexByBnum(bigarray)
  for i in 0...bigarray[1].length
  end
end

allinfo=stripInfo filename
writeToXls(allinfo, "CatNum")
  
