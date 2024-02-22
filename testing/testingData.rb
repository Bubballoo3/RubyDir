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


#Testing getCatType(categorizationNumber)

#function lives here
load 'prettyCommonFunctions.rb'

file=File.open 'testData.txt'
output=File.open('testoutput.txt','w')
file.each_line do |line|
    if line.length > 1
        output.write(line+" is type "+getCatType(line)+"\n")
        puts
    end
end

#Run on first 1-2000 categorization numbers stored in the Index on 2/21/24.
#   Results were good but errors appeared with numbers out of acceptible range
#   and alphanumerics not recognized #Unfixed


