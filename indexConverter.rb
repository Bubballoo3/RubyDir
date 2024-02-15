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
# Then the real file will start here

#we start by loading some universal functions
load 'prettyCommonFunctions.rb'

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
testslide="B13.012"
puts indexConverter(testslide)