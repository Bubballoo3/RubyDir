#Before making classes, we initialize constants that we will use throughout the program
# since each other file will load this one, all the files will have access to these 
# These constants may need to be updated, and should periodically be checked for accuracy
# These constants currently are, in order:
#   AcceptableAlphanumerics
#   BalyMaxNum



#This is an array of all the alphanumerics that make up the Baly classification system
AcceptableAlphanumerics=[
    #Authentic (created by Baly):
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","U","V","W","X","Y","Z",
    "AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK","AL","AM","AN","AO","AP","AQ","AR","AS","AT","AU","AV","AW","AX","AY","AZ",
    "BA","BB","BC","BD","BE","BF","BG","BH","BI","BJ","BK","BL","BM","BN","BQ","BR","BS","BT","BU","BV","BW","BX","BY","BZ",
    "CA","CB","CC","CD","CE","CF","CG","CH","CI","CJ","CK","CL","CM","CN","CO","CP","CQ","CR","CS","CT","CU","CV","CW","CX","CY","CZ",
    "DA","DB","DC","DD","DE","DF","DG","DH","DI","DJ","DK","DL","DM","DN","DO","DQ","DR","DS","DU","DV","DW","DX","DY","DZ",
    "EA","EB","EC","ED","EE","EF","EH","EJ","EK","EM","EN","EJB",
    #Artificial (created for unnumbered slides):
    "FL", #created to categorize the 88 slides at the end of B47 (stands for Fill)
    "NE", #created to allow production of trivial results for numbers VRC index skips. (stands for Non-Existent)
]

#The next constant records the highest number assigned across all the Baly collections.
# the current highest is in DK at 117. If a higher one is found, change this.
BalyMaxNum=117


#We start with our Error classes, which will allow us to identify
# specific issues and direct how to best resolve them
class ClassificationError < StandardError
end

class PrefixError < ClassificationError
end

class SuffixError < ClassificationError
end

class SortError < StandardError
end

class String
    def is_integer?
    self.to_i.to_s == self
    end
end

#The slide class is our main class, representing the info for a single slide. The goal is to have automated processes 
#read some data format, sort the data into the class variables, where it can be easily retrieved by some other form.
#we begin with methods specific to the slide class, and then we create subclasses for some of the more intricate data,
#such as classifications and locations.
class Slide
    def initialize(attributes)
        id=Classification.new(attributes)
        if id.classSystem == "Baly"
            @Balyid=id
            @VRCid=0
        elsif id.classSystem=="VRC"
            @Balyid=0
            @VRCid=id
        end
        @indexwriting=String.new
        @generalLocation=0
        @specificLocation=0
        @descriptionNotes
    end
    #accessor methods
    def balyGroup()
        return @Balyid.group()
    end
    def VRCGroup()
        return @VRCid.group()
    end

    def getindex(system=0)
        if system=="Baly"
            return @Balyid
        elsif system=="Baly"
            return @VRCid
        else
            [@Balyid,@VRCid].each do |id|
                if id != 0
                    return id
                end
            end
        end
    end
    def indexwriting()
        return @indexwriting
    end
    def generalLocation()
        return @generalLocation
    end
    def specificLocation()
        return @specificLocation
    end
    def descriptionNotes()
        return @descriptionNotes
    end


    def addAltID(input)
        if input.class != Classification
            id=Classification.new(input)
        else
            id=input
        end
        if id.classSystem == "Baly"
            if @Balyid==0
                @Balyid=id
            else
                raise StandardError.new "This slide has already been given a Baly ID. Once identification numbers are given, they cannot be changed."
            end
        elsif id.classSystem=="VRC"
            if @VRCid==0
                @VRCid=id
            else
                raise StandardError.new "This slide has already been given a VRC ID. Once identification numbers are given, they cannot be changed."
            end
        end
    end

    def addLocation(locationArray,specific=false,replace=false)
        prevLocations=[@generalLocation,@specificLocation]
        if replace == false and prevLocations != [0,0]
            if specific == false and prevLocations[0] != 0
                raise StandardError.new "This slide already has a general location, if you would like to override it, change the \'replace\' variable in the function call"
            elsif specific == true and prevLocations[1] != 0
                raise StandardError.new "This slide already has a specific location, if you would like to override it, change the \'replace\' variable in the function call"
            end
        end
        if specific == false
            @generalLocation=GeneralLocation.new(locationArray)
        elsif specific == true
            @specificLocation=SpecificLocation.new(locationArray)
        end
    end
end
#the following class parses and stores a classification number.
# The current class variables are:
#       input: Whatever input was used in the init function
#       group: The subcollection the number is a part of (B## or Alphanumeric)
#       number: The number in that collection, stored as an integer
#       stringform: The 
   
class Classification 
    def initialize(classnumber)
        if classnumber.class == String and classnumber.include?(".")
            @input=classnumber
            @stringform=classnumber
            (@group,rightside)=classnumber.split(".")
            @number=rightside.to_i
        elsif classnumber.class == Array and classnumber.length == 2
            @input=classnumber
            (@group,@number) = classnumber
            stringnum=@number.to_s
            while stringnum.length < 3
                stringnum = '0'+stringnum
            end
            @stringform=@group+'.'+stringnum
        else
            print "#{classnumber} is not a valid Classification object"
        end

        #the next part will make an attempt to identify the classification system. 
        # we already have a function that will do this, getCatType, but 
        if @group[0] == "B" and @group[-1].is_integer?
            @classSystem='VRC'
        elsif AcceptableAlphanumerics.include? @group
            @classSystem="Baly"
        else
            raise PrefixError.new "The Prefix #{@group} does not match any recorded collection. 
            Check for typos in your entry or amend AcceptableAlphanumerics"
        end
        if @classSystem == "Baly" and @number > BalyMaxNum
            raise SuffixError.new "The number #{@number} is higher than any recorded element in the Baly indexing system.
            Check for typos in your entry or change the constant BalyMaxNum"
        end 
    end

    def group()
        return @group
    end

    def number()
        return @number
    end

    def stringNum()
        num=@number.to_s
        while num.length < 3
            num="0"+num
        end
        return num
    end

    def to_s()
        return @stringform
    end

    def classSystem()
        return @classSystem
    end

    def inRange?(range)
        if range.include? "-"
            (leftside,rightside)=range.split("-")
            (rgroup,lownum)=leftside.split(".")
            hundreds=lownum[0]
            start=lownum.to_i
            if rightside.length < 3
                rightside=hundreds+rightside
            end
            last=rightside.to_i
            if @number >= start and @number <= last and @group == rgroup
                return true
            else
                return false
            end
        else
            return @stringform == range
        end
    end
end
class GeneralLocation
    def initialize(input)
        tuple=input[0]
        name=input[1]
        (@latitude,@longitude)=tuple
        @name=name
    end
    def coords()
        return [@latitude,@longitude]
    end
    def name()
        return @name
    end
end
class SpecificLocation
    def initialize(input)
        tuple=input[0]
        data=input[1]
        if data.class==String
            attributes=getAttributesFromString(data)
        elsif data.class==Array
            attributes=data[0..-1]
        end
        (@latitude,@longitude)=tuple
        @angle=Angle.new(attributes[0])
        @precision=attributes[1]
    end
    def coords()
        return [@latitude,@longitude]
    end
    def precision()
        return @precision
    end
    def angle()
        return @angle
    end
    def getAttributesFromString(stringin)
        (precisiondata,angledata)=stringin.split(" at ")
        print precisiondata,angledata
        if precisiondata.include? "location"
            precision=precisiondata.split(" ")[0].downcase
        else
            precision="exact"
        end
        if angledata.include? "degrees"
            angle=angledata
        else
            raise StandardError.new "No angle information was given, so this location cannot be specific."
        end
        return [angle,precision]
    end
    
    class Angle
        def initialize(stringin)
            elements=stringin.split(" ")
            (@degrees,middle,@direction)=elements
            if middle != "degrees"
                raise StandardError.new "word \'degrees\' not found/misplaced in angle data"
            end
        end
        def degrees()
            return @degrees
        end
        def direction()
            return @direction
        end
        def to_s() 
            return @degrees.to_s+" degrees "+@direction
        end
    end
end

sampleLocation=[[-2.27677,51.2792093],'estimated location at 70 degrees E']
#specificLocation=SpecificLocation.new(sampleLocation)


