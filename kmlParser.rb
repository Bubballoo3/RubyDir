=begin
This is a test document for Ruby explorations
---------------------------------------------
Include notes and advice in this section
----------------------------------------
=end

=begin
#This is an attempt to parse kml files into hashs for each item

file=File.open("UnitedKingdom.kml")

text=file.read
=end

#This is a github script found at https://gist.github.com/eliotk/7744806 that has been modified to interpret a single file from Google MyMaps.
=begin
require 'nokogiri'
require 'csv'

kml_path = '/path/to/Google Drive/My Tracks/'

#def kml_file_paths path
#  Dir.glob(path + "*.kml")
#end

csv = CSV.open('mytracks.csv', "wb")

#kml_file_paths(kml_path).each_with_index do |file_path, index|
file_path="UnitedKingdom.kml"
kml = File.read(file_path)
doc = Nokogiri::XML(kml)
  
  # summary data is stored as cdata in the last Placemark entity's description child node
desc_lines = doc.search('description').text.split(/\n/)
desc_lines.each do |reading|
  puts reading[1]
  puts "counting : #{reading.count("")}\n\n"
  puts "THAT WAS THE END OF THE DESCRIPTION"
 end
=end

#a purely original attempt

#some initial data

#this array contains all the keywords marking values we want to store. This uses the same strings used in the kml file.

filename="UnitedKingdom.kml"


                       
def stripInfo(kmlFilename)

  hashkeys=Array.new

  descriptions=Hash.new

  locations=Hash.new

  #Determine which file to read
  filename=kmlFilename

#define control variables
  num=0
  toread=false
  cordsread=false

#open file
  file=File.open(filename)


#read file one line at a time (master loop)
  File.readlines(file).each do |line|

    #Our first task is to collect the title of each entry
    #every title includes "<name>" and ends with "<\name>"
    if line.include? "<name>"
      endline=line.rindex "<"

      #titles including special characters have additional identifiers that must be removed 
      if line.include? "CDATA"
        splitline=line[21...endline-3]
 
      #the normal titles get cleaned here  
      else splitline=line[12...endline]
      end

      #items at the beginning and end of collections begin "(BXX)"
      #this also must be removed
      if splitline.include? "(B"
        splitline=splitline[6...]
      end
      title=splitline
      hashkeys.push title
    end

      #with our titles collected, we connect them to descriptions and locations using hashes

    #we begin with descriptions
    #search for our keyword
    if line.include? "<description>"
      endline=line.rindex "<"
      #split the line
      splitline=line[19...endline]
      activeDesc=splitline
      #reference our hashkeys list and create an entry in the descriptions hash
      descriptions[hashkeys[-1]]=activeDesc
    end

    #we then perform a simiilar process with the coordinates

  
    if cordsread==true
      cords=line[..-4]
      locations[hashkeys[-1]]=cords.lstrip!
      cordsread=false
    end

    if line.include? "<coordinates>"
      cordsread=true
    end
  end
  file.close()
  return[hashkeys,descriptions,locations]
end
allinfo=stripInfo filename

for i in hashkeys.length
  puts "TITLE "+allinfo[0][i]+" HAS DESCRIPTION "+allinfo[1][allinfo[0][i]]
end