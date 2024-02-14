#This script contains functions to convert from VRC indexing to Baly's indexing
# Baly's indexing was alphanumeric in groups of 100
# VRC indexing is decimalized with varying group sizes (usually 100/1000)
# Buckle in because these systems are so inconsistent
########################################################
# If you want to jump to the functions, skip to line 177
########################################################
#Bsorthash allows us to sort a VRC number into the appropriate hash for conversion
#one day we will have one that reverses this.
Bsorthash={"B01-41" => BHashNorm, "B42.0-43.9" => BhashRange, "B44.0-44.1" => B44hsh,"B44.2-44.8"=>BhashRange, "B44.9" => B44hsh}

#convertHashNorm contains subcollections that index normally.
# we can keep everything right of the decimal point and just change
# the beginning
convertHashNorm={
"A" => "B01",
"B" => "B02",
"C" => "B03",
"D" => "B04",
"E" => "B05",
"F" => "B06",
"G" => "B07",
"H" => "B08",
"I" => "B09",
"J" => "B10",
"K" => "B11",
"L" => "B12",
"M" => "B13",
"N" => "B14",
"O" => "B15",
"P" => "B16",
"R" => "B17",
"S" => "B18",
"T" => "B19",
"U" => "B20",
"V" => "B21",
"W" => "B22",
"X" => "B23",
"Y" => "B24",
"Z" => "B25",
"AA" => "B26",
"AB" => "B27",
"AC" => "B28",
"AD" => "B29",
"AE" => "B30",
"AF" => "B31",
"AG" => "B32",
"AH" => "B33",
"AI" => "B34",
"AJ" => "B35",
"AK" => "B36",
"AL" => "B37",
"AM" => "B38",
"AN" => "B39",
"AO" => "B40",
"AP" => "B41",
"AQ" => "B42"}


#this is an exact inversion of the one above
BHashNorm={
"B1"=>"A",
"B2"=>"B",
"B3"=>"C",
"B4"=>"D",
"B5"=>"E",
"B6"=>"F", 
"B7"=>"G", 
"B8"=>"H", 
"B9"=>"I", 
"B10"=>"J", 
"B11"=>"K", 
"B12"=>"L", 
"B13"=>"M", 
"B14"=>"N", 
"B15"=>"O", 
"B16"=>"P", 
"B17"=>"R", 
"B18"=>"S", 
"B19"=>"T", 
"B20"=>"U", 
"B21"=>"V", 
"B22"=>"W", 
"B23"=>"X", 
"B24"=>"Y", 
"B25"=>"Z", 
"B26"=>"AA", 
"B27"=>"AB", 
"B28"=>"AC", 
"B29"=>"AD", 
"B30"=>"AE", 
"B31"=>"AF", 
"B32"=>"AG", 
"B33"=>"AH", 
"B34"=>"AI", 
"B35"=>"AJ", 
"B36"=>"AK", 
"B37"=>"AL", 
"B38"=>"AM",
"B39"=>"AN",
"B40"=>"AO",
"B41"=>"AP",
}

BhashRange ={
"B42.001-100" => "AQ.1-100",
"B42.101-201" => "CU.1-100",
"B42.201-300" => "CV.1-100",
"B42.301-400" => "CW.1-100",
"B42.401-500" => "CX.1-100",
"B42.501-600" => "CY.1-100",
"B42.601-700" => "CZ.1-100",
"B42.701-800" => "DA.1-100",
"B42.801-900" => "DB.1-100",
"B42.901-999" => "DC.1-99",
"B43.000" => "DC.100",
"B43.001-100" => "DD.1-100",
"B43.101-200" => "DE.1-100",
"B43.201-300" => "DF.1-100",
"B43.301-400" => "DG.1-100",
"B43.401-500" => "DQ.1-100",
"B43.501-600" => "DR.1-100",
"B43.601-700" => "DS.1-100",
"B43.701-800" => "EE.1-100",
"B43.801-900" => "DT.1-100",
"B43.901-999" => "None",
"B44.201-300" => "AR.1-100",
"B44.301-400" => "AS.1-100",
"B44.401-500" => "AT.1-100",
"B44.501-600" => "AU.1-100",
"B44.601-700" => "AV.1-100",
"B44.701-800" => "AW.1-100",
"B44.801-900" => "AX.1-100"
}
=begin
  


convertHashIrreg={
"AR" => "B44.2"
"AS" => "B44.3"
"AT" => "B44.4"
"AU" => "B44.5"
"AV" => "B44.6"
"AW" => "B44.7"
"AX" => "B44.8"
"AY" => AYhsh
"AZ" => AVhsh
"BA" => BAhsh
"BB" => BBhsh
"BC" => BChsh
"BD" => Bhsh12
"BE" => Bhsh12
"BF" => Bhsh12
"BG" => Bhsh12
"BH" => Bhsh12
"BI" => 
"BJ" => 
"BK" => 
"BL" => 
"BM" => 
"BN" => 
"BO" => 
"BP" => 
"BQ" => 
"BR" => 
"BS" => 
"BT" => 
"BU" => 
"BV" => 
"BW" => 
"BX" => 
"BY" => 
"BZ" => 
}

=end

#Once the hashes above are complete, they will be moved to their own file
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