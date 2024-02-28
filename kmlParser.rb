=begin
This is a test document for Ruby explorations
---------------------------------------------
Include notes and advice in this section
----------------------------------------
=end

#load accessory files
#make sure you're in the right directory when you run this 
# or it won't be able to find the file
require_relative 'prettyCommonFunctions'

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


#puts parseSlideRange "B45.321 approximate location at 35 degrees N"
#"B27.012-15, B47.654-63, 716-18,B45.9-10, B45.63-67. WHat the"

def indexByBnum(bigarray)
  for i in 0...bigarray[1].length
  end
end

allinfo=stripInfo filename
writeToXls(allinfo, "CatNum")
  
