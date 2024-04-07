
load 'prettyCommonFunctions.rb'
=begin
Testrange="A.001,AB.24-43,B35.235-60,80,995-1000"
def testParse(string)
  #this will be our array that we return at the end
  slidesMentioned=Array.new
  collectionsToIndex=Hash.new

  #we begin by splitting the ranges. 
  #Ranges are separated by commas, and common info is not repeated
  #an especially complicated example of this is 
  #"B27.012-15, B45.905-06, B47.654-63, 716-18"
  ranges=prepareRanges(string)
  #next we store each B-collection in case the next one reuses it
  lastcollection="ERROR"
  thousandslide="NONE"
  #we now loop through the ranges and process them
  ranges.each do |range|
    
    #the following will be a sample range to indicate which parts the code is handling
    
    #B22.222-22  
    #   ^
    if range.include? "."
      (leftside,rightside)=range.split(".")
    else
      #in case it is only 222-22 
      rightside=range
      leftside="NONE"
    end
    
    #B22.222-22
    #^^^
    
    #B22.222-22
    #       ^
    unless leftside=="NONE"
      lastcollection = getSubcollection(leftside,rightside)
    end

    if rightside.include? "-"
      rightside=regularizeRightside(rightside)
      dashplace=4
      (start,last)=rightside.split "-"
      (start,last)=[start.to_i,last.to_i]
      #difference=(last/100)-start/100
      if last == 1000
        last=999
        thousandslide = lastcollection.to_s.split(".")[0]+"."+"1000"
      end
      #print start,last
      #puts [rightside,hundreds,start,last] 
      for i in start..last
        length=i.to_s.length
        if length < 3
          if length < 2
            ending=lastcollection.hundreds()+"0"+i.to_s
          else
            puts lastcollection.hundreds
            ending=lastcollection.hundreds()+i.to_s 
          end
        else
          ending=i.to_s
        end
        prefix=lastcollection.group
        slide=prefix+"."+ending
        slidesMentioned.push slide
        collectionsToIndex[prefix]=slide
      end
      if thousandslide != "NONE"
        slidesMentioned.push thousandslide
      end
    else
      length=rightside.length
      if length==3
        slide=lastcollection.group+"."+rightside
      elsif length == 2
        slide=lastcollection.to_s+rightside
      elsif length == 1
        if slidesMentioned.length > 0
          slide=slidesMentioned[-1][0...-1]+rightside
        else
          slide=lastcollection.to_s+"0"+rightside
        end
      end
      slidesMentioned.push slide
    end
  end
  minslide=slidesMentioned[0]
  maxslide=slidesMentioned[-1]  
  return [slidesMentioned,minslide,maxslide]
  #we begin by splitting our description up by subcollection.
end

def prepareRanges(string)
  if string.include? ". "
    n=string.index ". "
    string=string[...n]
  end
  ranges=string.split(",",-1)
  for i in 0...ranges.length
   ranges[i] = ranges[i].lfullstrip
  end
  return ranges
end
def getSubcollection(leftside,rightside)
  dashplace=findendplace(rightside)
  if dashplace < 3
    lastcollection=Subcollection.new(leftside+"."+"0")
  else
    lastcollection=Subcollection.new(leftside+'.'+rightside[0])
  end
  return lastcollection 
end
def findendplace(rightside)
  unless rightside.include? "-" 
    count=0
    endplace=rightside.length
    rightside.each_char do |char|
      if char.is_integer?
        count+=1
      else
        endplace=count
      end
    end
  else
    endplace=rightside.index "-"
  end
  return endplace
end
def regularizeRightside(rightside)
  endplace=findendplace(rightside)
  while endplace < 3
    puts endplace
    rightside="0"+rightside
    endplace+=1
  end
  if rightside.include?("-")
    lastpart=rightside.split("-")[1]
    while lastpart.is_integer? == false
      lastpart=lastpart[0...-1]
    end
    count=0
    while lastpart.length < 3
      lastpart=rightside[count]+lastpart
      count+=1
      rightside=rightside[0..endplace]+lastpart
    end
  end
  return rightside
end
=end
def readXLScolumn(xlsfile,worksheet,columnNum)
  require 'spreadsheet'
  Spreadsheet.client_encoding = 'UTF-8'
  book = Spreadsheet.open xlsfile
  sheet=book.worksheet 0
  
  indexarray=Array.new
  sheet.each do |row|
    eachindex=row[columnNum]
    indexarray.push eachindex
  end
  return indexarray
end

array=readXLScolumn("United Kingdom48.3.xls",0,1)
array.each do |element|
  puts element.class
end

AllAlphanumerics=[ 
    "A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK","AL","AM","AN","AO","AP","AQ","AR","AS","AT","AU","AV","AW","AX","AY","AZ",
    "BA","BB","BC","BD","BE","BF","BG","BH","BI","BJ","BK","BL","BM","BN","BO","BP","BQ","BR","BS","BT","BU","BV","BW","BX","BY","BZ",
    "CA","CB","CC","CD","CE","CF","CG","CH","CI","CJ","CK","CL","CM","CN","CO","CP","CQ","CR","CS","CT","CU","CV","CW","CX","CY","CZ",
    "DA","DB","DC","DD","DE","DF","DG","DH","DI","DJ","DK","DL","DM","DN","DO","DP","DQ","DR","DS","DT","DU","DV","DW","DX","DY","DZ",
    "EA","EB","EC","ED","EE","EF","EG","EH","EI","EJ","EK","EL","EM","EN","EO","EP","EQ","ER","ES","ET","EU","EV","EW","EX","EY","EZ",
    "FA","FB","FC","FD","FE","FF","FG","FH","FI","FJ","FK","FL","FM","FN","FO","FP","FQ","FR","FS","FT","FU","FV","FW","FX","FY","FZ",
    "GA","GB","GC","GD","GE","GF","GG","GH","GI","GJ","GK","GL","GM","GN","GO","GP","GQ","GR","GS","GT","GU","GV","GW","GX","GY","GZ",
    "HA","HB","HC","HD","HE","HF","HG","HH","HI","HJ","HK","HL","HM","HN","HO","HP","HQ","HR","HS","HT","HU","HV","HW","HX","HY","HZ",
    "IA","IB","IC","ID","IE","IF","IG","IH","II","IJ","IK","IL","IM","IN","IO","IP","IQ","IR","IS","IT","IU","IV","IW","IX","IY","IZ",
    "JA","JB","JC","JD","JE","JF","JG","JH","JI","JJ","JK","JL","JM","JN","JO","JP","JQ","JR","JS","JT","JU","JV","JW","JX","JY","JZ",
    "KA","KB","KC","KD","KE","KF","KG","KH","KI","KJ","KK","KL","KM","KN","KO","KP","KQ","KR","KS","KT","KU","KV","KW","KX","KY","KZ",
    "LA","LB","LC","LD","LE","LF","LG","LH","LI","LJ","LK","LL","LM","LN","LO","LP","LQ","LR","LS","LT","LU","LV","LW","LX","LY","LZ",
    "MA","MB","MC","MD","ME","MF","MG","MH","MI","MJ","MK","ML","MM","MN","MO","MP","MQ","MR","MS","MT","MU","MV","MW","MX","MY","MZ",
    "NA","NB","NC","ND","NE","NF","NG","NH","NI","NJ","NK","NL","NM","NN","NO","NP","NQ","NR","NS","NT","NU","NV","NW","NX","NY","NZ",
    "OA","OB","OC","OD","OE","OF","OG","OH","OI","OJ","OK","OL","OM","ON","OO","OP","OQ","OR","OS","OT","OU","OV","OW","OX","OY","OZ",
    "PA","PB","PC","PD","PE","PF","PG","PH","PI","PJ","PK","PL","PM","PN","PO","PP","PQ","PR","PS","PT","PU","PV","PW","PX","PY","PZ",
    "QA","QB","QC","QD","QE","QF","QG","QH","QI","QJ","QK","QL","QM","QN","QO","QP","QQ","QR","QS","QT","QU","QV","QW","QX","QY","QZ",
    ]