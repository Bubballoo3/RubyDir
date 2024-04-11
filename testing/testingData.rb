#This file is a really good one for testing a function on a large batch of data that we have. 

#To Use:
#   Copy any large section of the index into the testData.txt file
  #  
#   Copy paste the function below and comment out the old one
  #
#   Modify the function and output for the code you are testing
  #
#   Output will be stored in output.txt file (iterate or randomize to save each run)
  #
#   record input and results below each function

=begin
#Testing getCatType(categorizationNumber)

#function lives here
load 'prettyCommonFunctions.rb'

file=File.open 'testing/testData.txt'
output=File.open('testing/testoutput.txt','w')
file.each_line do |line|
  if line.length > 1
    output.write(line+" is type "+getCatType(line)+"\n")
    puts
  end
end

#Run on first 1-2000 categorization numbers stored in the Index on 2/21/24.
#   Results were good but errors appeared with numbers out of acceptible range
#   and alphanumerics not recognized #Unfixed
=end

=begin #This is testing the int method alphValue versus the list index method of reading alphanumerics
load 'prettyCommonFunctions.rb'
load 'Sample.rb'

AllAlphanumerics.each do |i|
  methval=i.alphValue
  print "#{i} => #{methval} | "
end
puts "XE".alphValue 
puts generateSortingNumbers(["DD.001"])
puts "ZZ".alphValue
puts generateSortingNumbers(["ZZ.001"])
puts "AAA".alphValue
puts generateSortingNumbers(["AAA.001"])
=end 

#testing indexConverter from Baly to VRC
#we write a simple test that will make sure conversion is invertible
load 'indexConverter.rb'
def testConversion(slide)
  return slide.to_s == indexConverter(indexConverter(slide)).to_s
end

def testConvertRange(range)
  puts range
  sliderange=parseSlideRange(range)[0]
  returnhash=Hash.new
  sliderange.each do |slide|
    returnhash[slide]=testConversion(slide)
  end
  return returnhash
end

def testConvertHash(hash)
  hash.keys.each do |key|
    puts testConvertRange(key)
  end
end