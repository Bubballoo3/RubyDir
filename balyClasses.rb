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
    "CA","CB","CC","CD","CE","CF","CH","CI","CJ","CK","CL","CM","CN","CO","CP","CQ","CR","CS","CT","CU","CV","CW","CX","CY","CZ",
    "DA","DB","DC","DD","DE","DF","DG","DH","DI","DJ","DK","DL","DM","DO","DQ","DR","DS","DU","DV","DW","DX","DY","DZ",
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

class Slide
    def initialize(categorization)
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

class String
    def is_integer?
      self.to_i.to_s == self
    end
end