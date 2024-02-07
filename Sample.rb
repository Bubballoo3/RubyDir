=begin 
Ruby program to find Area of Rectangle.

# input length and breadth, and 
# convert them to float value
puts "Enter length:"
l=gets.chomp.to_f
puts "Enter width:"
w=gets.chomp.to_f
# calculating area 
area=l*w
# printing the result
puts "Area of Rectangle is #{area}"
=end
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
      puts range
      
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
      

      puts "resolved"
    end
    return slidesMentioned
    #we begin by splitting our description up by subcollection. 
  end 
  #parseSlideRange "B27.012-15, B47.654-63, 716-18,B45.9-10, B45.63-67. WHat the"