require_relative 'balyClasses.rb'

Threeletterclassifications=["EJB"]
#This file is meant to be loaded at the start of more specific files.
# It contains functions that we will use a lot in different applications.

#the first one takes a slide range as a string and outputs a list of all the slides in that range.
# 
# ASIDE: This is the key to time efficient data entry. There are many parts of the collection which are
#        consistent in some aspect with unpredictable and varying interruptions (eg. classification methodology).
#         
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
      ranges[i] = ranges[i].lfullstrip
    end
    #next we store each B-collection in case the next one reuses it
    lastcollection="ERROR"
  
    #we now loop through the ranges and process them
    ranges.each do |range|
      
      #the following will be a sample range to indicate which parts the code is handling
      
      #B22.222-22  
      #   ^
      if range.include? "."
        rightside=range.split(".")[1]
      else
        #in case it is only 222-22 
        decimalpoint=0
        rightside=range
      end
      
      #B22.222-22
      #^^^
      if range[0]=="B"
        lastcollection=range.split('.')[0]
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
        if last.to_s.length > 2
            last=(last-hundreds.to_i*100)
        end
        #puts [rightside,hundreds,start,last] 
        for i in start..last
            if i < 100
                slidestem=lastcollection + "." + hundreds
            else
                slidestem=lastcollection+"."+(i/100+hundreds.to_i).to_s
                i=i%100
            end
          if i.to_s.length < 2
            ending="0"+i.to_s
          else 
            ending=i.to_s
          end
          slide=slidestem+ending
          slidesMentioned.push slide
        end
      else 
        while rightside.length <3
            rightside="0"+rightside
        end
        slide=lastcollection+"."+rightside
        slidesMentioned.push slide
      end
    end
  
    slidesMentioned=slidesMentioned.sort
    if slidesMentioned[0].class != NilClass
      if slidesMentioned[0][4..] == 1000
        slidesMentioned=slidesMentioned.rotate(1) 
      end
    end
    minslide=slidesMentioned[0]
    maxslide=slidesMentioned[-1]
    return [slidesMentioned,minslide,maxslide]
    #we begin by splitting our description up by subcollection. 
end
######### Known Errors ########################################################
## There is an error that needs fixing involving ranges ending in/crossing 1000#
   # fixing in progress, .rotate seems ineffective


=begin #The following is a debug routine that allows you to repeatedly test ranges
s=""
puts "a debug session has started. enter \"n\" at any time to end it"
while s != "n"
  unless s==""
    puts parseSlideRange(s)
  end
  s=gets
end
=end


######### Fresh Attempt using Classes ##########################################
#the next functions, parseSlideRangeAttempt, prepareRanges, getsubcollection,findendplace, 
# and regularizeRightSide are part of this attempt, currently unsuccessful.
# The smaller functions may have other uses, but still need to be rigorously tested
def parseSlideRangeAttempt(string)
  #this will be our array that we return at the end
  slidesMentioned=Array.new
  collectionsToIndex=Hash.new

  #we begin by splitting the ranges. 
  #Ranges are separated by commas, and common info is not repeated
  #an especially complicated example of this is 
  #"B27.012-15, B45.905-06, B47.654-63, 716-18"
  ranges=prepareRanges(string)
  #next we store each B-collection in case the next one reuses it
  lastcollection="ERROR"
  thousandslide="NONE"
  #we now loop through the ranges and process them
  ranges.each do |range|
    
    #the following will be a sample range to indicate which parts the code is handling
    
    #B22.222-22  
    #   ^
    if range.include? "."
      (leftside,rightside)=range.split(".")
    else
      #in case it is only 222-22 
      rightside=range
      leftside="NONE"
    end
    
    #B22.222-22
    #^^^
    
    #B22.222-22
    #       ^
    unless leftside=="NONE"
      lastcollection = getSubcollection(leftside,rightside)
    end

    if rightside.include? "-"
      rightside=regularizeRightside(rightside)
      dashplace=4
      (start,last)=rightside.split "-"
      (start,last)=[start.to_i,last.to_i]
      #difference=(last/100)-start/100
      if last == 1000
        last=999
        thousandslide = lastcollection.to_s.split(".")[0]+"."+"1000"
      end
      #print start,last
      #puts [rightside,hundreds,start,last] 
      for i in start..last
        length=i.to_s.length
        if length < 3
          if length < 2
            ending=lastcollection.hundreds()+"0"+i.to_s
          else
            puts lastcollection.hundreds
            ending=lastcollection.hundreds()+i.to_s 
          end
        else
          ending=i.to_s
        end
        prefix=lastcollection.group
        slide=prefix+"."+ending
        slidesMentioned.push slide
        collectionsToIndex[prefix]=slide
      end
      if thousandslide != "NONE"
        slidesMentioned.push thousandslide
      end
    else
      length=rightside.length
      if length==3
        slide=lastcollection.group+"."+rightside
      elsif length == 2
        slide=lastcollection.to_s+rightside
      elsif length == 1
        if slidesMentioned.length > 0
          slide=slidesMentioned[-1][0...-1]+rightside
        else
          slide=lastcollection.to_s+"0"+rightside
        end
      end
      slidesMentioned.push slide
    end
  end
  minslide=slidesMentioned[0]
  maxslide=slidesMentioned[-1]  
  return [slidesMentioned,minslide,maxslide]
  #we begin by splitting our description up by subcollection.
end

def prepareRanges(string)
  if string.include? ". "
    n=string.index ". "
    string=string[...n]
  end
  ranges=string.split(",",-1)
  for i in 0...ranges.length
   ranges[i] = ranges[i].lfullstrip
  end
  return ranges
end
def getSubcollection(leftside,rightside)
  dashplace=findendplace(rightside)
  if dashplace < 3
    lastcollection=Subcollection.new(leftside+"."+"0")
  else
    lastcollection=Subcollection.new(leftside+'.'+rightside[0])
  end
  return lastcollection 
end
def findendplace(rightside)
  unless rightside.include? "-" 
    count=0
    endplace=rightside.length
    rightside.each_char do |char|
      if char.is_integer?
        count+=1
      else
        endplace=count
      end
    end
  else
    endplace=rightside.index "-"
  end
  return endplace
end
def regularizeRightside(rightside)
  endplace=findendplace(rightside)
  while endplace < 3
    puts endplace
    rightside="0"+rightside
    endplace+=1
  end
  if rightside.include? "-"
    lastpart=rightside.split("-")[1]
    while lastpart[-1].is_integer? == false
      lastpart=lastpart[0...-1]
    end
    count=0
    while lastpart.length < 3
      lastpart=rightside[count]+lastpart
      count+=1
      rightside=rightside[0..endplace]+lastpart
    end
  end
  return rightside
end

#The next function takes a slide categorization number and returns if it is an element of the 
# VRC or Baly categorization system. It does not reference a database, but just uses the 
# conventions of each to determine which it belongs to. Thus a slide C.400 would be sorted 
# into the baly system even though no such slide exists. However we will check the prefix 
# and some details about the suffix to raise errors as soon as possible.

#This function has been effectively replaced by the indexSystem attribute for classifications.
# Once classificationData.rb includes every (known) slide in the collection,
# this function will be improved to check against data and be more precise than inRange?.
# Until then, get the classification system by entering 
#  "Classification.new(classificationstring).indexSystem"
def getCatType(catnum)
  #first we use the prefix of the classification number (the bit before the decimal point) and make 
  # a first guess about the sort. This will allow us to check some more specific conventions for each
  if catnum[0] != "B"
    hypothesis="Baly"
  elsif catnum[1] == "."
    hypothesis="Baly"
  elsif [0,1,2,3,4,5,6,7,8,9].include? catnum.split('.')[1][-1]
    hypothesis="VRC"
  end
  (prefix,suffix)=catnum.split(".")
  
  if hypothesis == "Baly"
    if AcceptableAlphanumerics.include? prefix
      #The 118 below is nothing more than the largest number we have indexed in a collection thus far
      # If errors are occurring in the higher numbers, look here. 
      if suffix.to_i <= BalyMaxNum
        return "Baly"
      else         
        return "N/A" 
        print "Subcollection #{prefix} doesn't include that number (#{suffix})"
        puts
      end
    else 
      return "N/A" 
      print "This alphanumeric (#{prefix})was not used by Baly"
      puts
    end
  end

  if hypothesis == "VRC"
    if prefix[1..].to_i < 42
      #The 117 below is nothing more than the largest number we have indexed in a collection thus far
      # If errors are occurring in the higher numbers, look here. 
      if suffix.to_i < 118 
        return "VRC"
      else
        return "N/A" 
        print "Subcollection #{prefix} doesn't include that number (#{suffix})"
        puts
      end
    elsif prefix [1..].to_i < 51
      if suffix.to_i < 1001
        return "VRC"
      else
        return "N/A" 
        print "Subcollection #{prefix} doesn't include that number (#{suffix})"
        puts
      end
    else
      return "N/A" 
      print "This alphanumeric (#{prefix})was not used by Baly"
      puts
    end
  end
  return "N/A"
  puts "If its made it this far the slide cannot be sorted"
end
=begin #testing code
testslide="B12.045"
while testslide != "n"
    testslide=gets
    puts getCatType(testslide)
end
=end
def generateUniqueFilename(filetype="xls",someTitle)
  time=Time.now
  minutes=time.min
  seconds=time.sec
  filename=someTitle+minutes.to_s + "." + seconds.to_s+"."+filetype
  return filename
end

def generateSortingNumbers(array)
  sortingNumbers=Array.new
  array.each do |cat|
    if cat.class == NilClass
      sortingNumbers.append ""
    elsif cat.length < 2
      sortingNumbers.append ""
    elsif Threeletterclassifications.include? cat
      sortingNumbers.append ""
    else
      classification=Classification.new(cat)
      if classification.classSystem != "Baly"
        sortingNumbers.append ""
      end
      decimalgroup=AllAlphanumerics.index classification.group
      decimalgroup+=1
      groupvalue=decimalgroup*1000
      numvalue=classification.number
      if numvalue > 1000
        raise StandardError "Baly Classification dont have #{numvalue} slides. If there's one that does, overhaul the whole system ig :/"
      end
      sortingnum=groupvalue+numvalue
      sortingNumbers.append sortingnum
    end
  end
  return sortingNumbers
end

