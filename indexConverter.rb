#This script contains functions to convert from VRC indexing to Baly's indexing
# Baly's indexing was alphanumeric in groups of 100
# VRC indexing is decimalized with varying group sizes (usually 100/1000)
# Buckle in because these systems are so inconsistent

#The concept is to store the classification data in ranges, allowing us to compress the data.
#This allows for faster data entry while still accounting for unpredictable exceptions.
#In order to keep our hashes orderly, we currently limit coverage to 1000 slides for each rangehash
# we can then run the following routines to parse these rangehashes and produce an output.

# The only exception is BHashNorm, since those are so straightforward we can save some computation by doing them separately.

#Bsorthash allows us to sort a VRC number into the appropriate hash for conversion.
#one day we will have one that reverses this.
Bsorthash={"B01-41" => "BHashNorm", "B42.0-43.9" => "BhashRange", "B44.0-44.1" => "B44to45hash",
           "B44.2-44.8"=>"BhashRange", "B44.9" => "B44-45hash","B45.0-B45.2" => "B44to45hash",
           "B46.0-B46.9" => "B46hash","B47.0-47.9" => 'B47hash'}
#then we make a similar hash for Baly numbers, but we use the sorting numbers so we can capture the ranges
BalySorthash={"1000-42200" => 'ConvertHashNorm','43000-50200' => 'BhashRange','99000-124200' => 'BhashRange',
              '135000-135200' => 'BhashRange','51000-62015' => 'B44to45hash','62016-74066' => 'B46hash', 
              '26056-26100' => 'B47hash', '74000-83200' => 'B47hash','103085-103100'=> 'B47hash',
              '85000-98200' => 'B48to49hash',
            
            #we also include maps for the invented numbers, but these will probably be used rarely since we should prefer VRC numbers for slides that lack Baly ones
            '168000-168200'=>'B46hash','184000-184200'=>'B46hash',
            '629000-629001'=>'B47hash', '168000-168088'=>'B47hash', #also EJB if that gets a number
            '168089-168100'=> 'B48to49hash'
        }
#Once the hashes above are complete, they will be moved to their own file
# Then the real file will start here

#first we load our classes
require_relative 'balyClasses'
#we then load some universal functions
require_relative 'prettyCommonFunctions'
#Then we load our data 
require_relative 'classificationData'

#then we start with our index converter function

#The following component function expands the subcollection ranges found in Bsorthash. 
# This allows us to search each range for the subcollection we are dealing with
def expandBhashRange(brange,includeLeadingZeros=true)
    #initialize return array
    expandedRange=Array.new
    #strip the "B" from the start of the range
    noBrange=brange[1..]
    #check that we are indeed dealing with a range, if it's a single collection, we return a singleton array
    unless noBrange.include? "-"
        return [brange]
    end
    #split by the dash to get the starts and ends of our range
    (start,last) = noBrange.split "-"
    
    # Here we split into cases depending on whether we are looking at subcollections of 100s or 1000s
    # Subcollections of 1000s look like B43.2 (=B43.200-300) and 100s look like B41 (=B41.001-100)
    if start.include? "."
        (startInt,lastInt)=[start.delete(".").to_i,last.delete(".").to_i]
        for i in startInt..lastInt
            #by removing the decimal point, we scaled our numbers up by a factor of 10 (in order to make them integers)
            unscaledNum=i.to_s
            #to scale it back, we insert it back in its place
            scaledNum=unscaledNum.insert(2,".")
            subcollection="B"+scaledNum
            #we finally push the range element into our return array
            expandedRange.push subcollection
        end

    else   #if there is no decimal point, we know we are looking at a 100s collection.
        (startInt,lastInt)=[start.to_i,last.to_i]
        for i in startInt..lastInt
            #since it is not consistent whether subcollections before B10 are written as B5 or B05, 
            # we have an option to put them both in to be safe. 
            if i<10
                if includeLeadingZeros==true
                    expandedRange.push "B"+i.to_s
                end
                catnum="0"+i.to_s
            else
                catnum=i.to_s
            end
            subcollection="B"+catnum
            expandedRange.push subcollection
        end
    end
    return expandedRange
end

=begin #Testing Code for expandBhashRange
# As Bsorthash grows to include up to B51, this should be run periodically to ensure it still works. 
# Currently tested up to B44.9
Bsorthash.keys.each do |key|
    print [key,expandBhashRange(key)]
end
=end

#Our next function uses these expanded ranges to sort a slide into one of them
def getBsorthashkey(slide)
    if slide.include? "."
        ans=""
        (leftside,rightside)=slide.split "."
        if leftside[1..].to_i > 41 #41 is the last VRC collection of 100
            unless rightside [-2..] == "00"
                hundreds=rightside[0]
            else 
                hundreds=(rightside[0].to_i - 1).to_s
            end
            leftside=leftside+"."+hundreds
        end
        Bsorthash.keys.each do |key|
            if expandBhashRange(key).include? leftside
                ans=key
                return ans
            end
        end
        if ans == ""
            puts "The slide could not be sorted. Check that it is within the range spanned by Bsorthash"
        end
    else
        puts "This slide has no decimal point. Make sure to include the full indexing"
    end
end

=begin Testing Code for getBsorthashkey
 #test a member of each range in Bsorthash just to be safe
puts getBsorthashkey "B24.145"
puts getBsorthashkey "B44.145"
puts getBsorthashkey "B42.145"
puts getBsorthashkey "B44.200"
=end

#the next function takes two equally sized ranges as inputs,
#and returns a hash that contains each element 
#of the 'domain' range mapped to the 'codomain' range
#   (the order of the hash is determined by the order of the inputs)

def projectRange(domain,codomain)
    print "WORK ON ME!!"
end

#sometimes we wont need to get a custom dictionary 
# if we only have one slide to map, we have a more efficient 
# function here to do just that.

def translateRangeElement(slideindx,domain,codomain)
    #split left and right side of each range
    (dleft,dright)=domain.split("-")
    (cleft,cright)=codomain.split("-")
    #since right sides can omit the hundreds place, we fill it in 
    #if it is missing and convert to integer
    if dright.length < 3
        dright=((dleft.split(".")[1].to_i/100).to_s+dright).to_i
    end
    if cright.length < 3
        cright=((cleft.split(".")[1].to_i/100).to_s+cright).to_i
    end
    # filter each piece to the numbers
    dombase=dleft.split(".")[1].to_i
    cobase=cleft.split(".")[1].to_i
    slidenum=slideindx.number
    #check that the slide is actually in the range
    # this will help us catch errors in larger fxns that pass faulty arguments
    unless slideindx.inRange? domain
        raise StandardError.new "slide #{slideindx.to_s} is outside domain"
    else 
        #puts dright,dombase,cright,cobase
        if dright.to_i-dombase != cright.to_i-cobase
            
            raise StandardError.new "domain (#{domain}) and codomain are different sizes"
        end
    end
    if dombase != cobase
        scale=cobase-dombase
        tlatednum=(slidenum+scale).to_s
        while tlatednum.length < 3
            tlatednum = "0"+tlatednum
        end
    elsif dombase == cobase
        tlatednum=slidenum
    end
    newprefix=cleft.split(".")[0]
    newslide=Classification.new([newprefix,tlatednum.to_i])
    return newslide
end

=begin #testing
puts translateRangeElement("D.033","D.020-40","B43.056-76")
puts translateRangeElement("B43.045","B43.035-92","C.001-58")
puts translateRangeElement("B43.030","B43.035-92","C.001-58")
=end
def scanRangeHash(slideindx,activehash)
    slidestring=slideindx.to_s
    if activehash.keys.include? slidestring
        newslide=Classification.new(activehash[slidestring])
    else
        rng=""
        activehash.keys.each do |key|
            if slideindx.inRange? key
                rng=key
                break
            end
            #print slide, parseSlideRange(key)[0], (parseSlideRange(key)[0].include? slide)
            #puts
        end
        if rng == ""
            raise SortError.new "slide #{slidestring} could not be found in this hash"
        end
        newslide=translateRangeElement(slideindx,rng,activehash[rng])
    end
    return newslide
end
=begin #testing
puts scanB47hash('B47.035')
puts scanB47hash('B47.005')
=end

#this function currently has capability for BHashNorm and B47hash ranges
def indexConverter(slide,outputform='String')
    if slide.class == String
        slideindx=Classification.new(slide)
        slidestring=slide
        #print "a string was input"
    elsif slide.class == Classification
        slideindx=slide
        slidestring=slide.to_s
        #print "a Classification was input"
    end
    #print slideindx.class,slidestring.class

    if slideindx.classSystem == "VRC"
        hashtouse=Bsorthash[getBsorthashkey(slidestring)]
        puts [hashtouse,slidestring]
        if hashtouse=="BHashNorm"
        ##############################################################################    
        #this is where we will eventually check an index of inconsistencies in the normal hash.
        ##############################################################################
            newleftside=BHashNorm[slideindx.group]
            newslide=Classification.new([newleftside,slideindx.number])
            print newslide.class
        elsif hashtouse=='BhashRange'
            newslide=scanRangeHash(slideindx,BhashRange)
        elsif hashtouse=='B44to45hash'
            newslide=scanRangeHash(slideindx,B44to45hash)
        elsif hashtouse=='B46hash'
            newslide=scanRangeHash(slideindx,B46hash)
        elsif hashtouse=='B47hash'
            newslide=scanRangeHash(slideindx,B47hash)
        elsif hashtouse=='B48to49hash'
            newslide=scanRangeHash(slideindx,B48to49hash)
        end
    elsif slideindx.classSystem == "Baly"
       return "We cannot convert Baly indexes to VRC yet" 
    end
    return newslide
end

=begin #testing code
testslide="B12.045"
while testslide != "n"
    testslide=gets[0...-1]
    unless testslide == 'n'
        puts indexConverter(testslide)
    end
end
=end
#test results:
#   Successfully converted B47.001-999 and B42.001-999