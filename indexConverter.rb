#This script contains functions to convert from VRC indexing to Baly's indexing
# Baly's indexing was alphanumeric in groups of 100
# VRC indexing is decimalized with varying group sizes (usually 100/1000)
# Buckle in because these systems are so inconsistent
########################################################
# If you want to jump to the functions, skip to line 177
########################################################
#Bsorthash allows us to sort a VRC number into the appropriate hash for conversion.
#one day we will have one that reverses this.
Bsorthash={"B01-41" => "BHashNorm", "B42.0-43.9" => "BhashRange", "B44.0-44.1" => "B44hsh","B44.2-44.8"=>"BhashRange", "B44.9" => "B44hsh"}

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
# Then the real file will start here

#we start by loading some universal functions
load 'prettyCommonFunctions.rb'
#Then we load our data 
load 'classificationData.rb'

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

=begin Testing Code for expandBhashRange
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
        if leftside[1..].to_i > 41
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

def indexConverter(slide)
    if slide[0]=="B"
        if slide.include? "."
            (leftside,rightside)=slide.split "."
            while rightside.length <= 3
                rightside="0"+rightside
            end
            hashtouse=Bsorthash[getBsorthashkey(slide)]
            if hashtouse=="BHashNorm"
            ##############################################################################    
            #this is where we will eventually check an index of inconsistencies in the normal hash.
            ##############################################################################
                newleftside=BHashNorm[leftside]
                newslide=newleftside+"."+rightside
                return newslide
            end
        else 
            puts "This slide has no decimal point. Make sure to include the full indexing"
        end
    else
        print "we're not ready for that silly"
    end
end

#testing code
testslide="B12.045"
while testslide != "n"
    testslide=gets
    puts indexConverter(testslide)
end
