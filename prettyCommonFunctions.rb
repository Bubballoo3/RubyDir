#load 'balyClasses.rb'
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
    if slidesMentioned[0][4..] == 1000
      slidesMentioned=slidesMentioned.rotate(1) 
      print "Did something "
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

#The next function takes a slide categorization number and returns if it is an element of the 
# VRC or Baly categorization system. It does not reference a database, but just uses the 
# conventions of each to determine which it belongs to. Thus a slide C.400 would be sorted 
# into the baly system even though no such slide exists. However we will check the prefix 
# and some details about the suffix to raise errors as soon as possible.

#It would be really nice to not load this giant data file each time but...
#load "classificationData.rb"

def getCatType(catnum)
  #first we use the prefix of the classification number (the bit before the decimal point) and make 
  # a first guess about the sort. This will allow us to check some more specific conventions for each
  if catnum[0] != "B"
    hypothesis="Baly"
  elsif catnum[1] == "."
    hypothesis="Baly"
  else
    hypothesis="VRC"
  end
  (prefix,suffix)=catnum.split(".")
  
  if hypothesis == "Baly"
    if AcceptableAlphanumerics.include? prefix
      #The 118 below is nothing more than the largest number we have indexed in a collection thus far
      # If errors are occurring in the higher numbers, look here. 
      if suffix.to_i < 118
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
