#Normal Hashes are used for A-AQ/B01-B41. These are largely the same numbers with different prefixes
#ConvertHashNorm contains subcollections that index normally.
# we can keep everything right of the decimal point and just change
# the beginning
ConvertHashNorm={
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
}


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
"B01"=>"A",
"B02"=>"B",
"B03"=>"C",
"B04"=>"D",
"B05"=>"E",
"B06"=>"F", 
"B07"=>"G", 
"B08"=>"H", 
"B09"=>"I", 
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
NormExceptions={
"B03.093" => "C.094",
"B03.094" => "C.093"    
}
#for BhashRange values are what we expect to find, 
# verified ranges marked with #V
BhashRange ={
"B42.001-100" => "AQ.1-100", #V
"B42.101-200" => "CU.1-100", #V
"B42.201-300" => "CV.1-100", #V
"B42.301-400" => "CW.1-100",
"B42.401-500" => "CX.1-100",
"B42.501-584" => "CY.1-84", #the missing CY's here can be found in B47.000s
"B42.586-587" => "CY.86-87",
"B42.590" => "CY.090",
"B42.591-592" => "CY.92-93",
"B42.599" => "CY.099",
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
"B43.901-999" => "UC.1-99", # UC stands for Unclassified by Baly
"B44.201-300" => "AR.1-100",
"B44.301-400" => "AS.1-100",
"B44.401-500" => "AT.1-100",
"B44.501-600" => "AU.1-100",
"B44.601-700" => "AV.1-100",
"B44.701-800" => "AW.1-100",
"B44.801-900" => "AX.1-100"
}
#the following group, B44.001-200, skips many slides and is very complex.
#As such, it has been placed in its own hash.
EKtoENhash={
"B44.001" => "EM.67",
"B44.002-009" => "EM.69-76",
"B44.010-015" => "EM.78-83",
"B44.016" => "EN.02",
"B44.017-018" => "EM.91-92",
"B44.019" => "EN.03",
"B44.020" => "EM.84",
"B44.21-30" => "EM.93-102",
"B44.031-032" => "EM.89-90",
"B44.033" => "EM.85",
"B44.034" => "EM.88",
"B44.035-039" => "EN.04-08",
"B44.040-041" => "EN.10-11",
"B44.042-051" => "EN.13-22",
"B44.052-053" => "EN.24-25",
"B44.054" => "EN.27",
"B44.055-056" => "EN.29-30",
"B44.057-058" => "EN.32-33",
"B44.059-061" => "EN.35-37",
###This group was formerly classified as EN.31-38, which conflicted with the slides above. See documentation for more details
"B44.062-069" => "EN.91-98",
#######################################
"B44.070-071" => "EN.41-42",
"B44.072-075" => "EN.45-48",
"B44.076-079" => "EN.50-53",
"B44.080" => "EN.56",
"B44.081-083" => "EN.58-60",
"B44.084" => "EN.62",
"B44.085-87" => "EN.64-66",
"B44.088" => "EN.70",
"B44.089-090" => "EN.73-74",
"B44.091-093" => "EN.76-78",
"B44.094-096" => "EN.82-84",
"B44.097" => "EN.90",
"B44.098" => "EN.85",
"B44.099" => "EN.87",
"B44.101" => "EK.70",
"B44.102" => "EK.67",
'B44.103' => "EK.69",
"B44.104-105" => "EK.72-73",
"B44.106-107" => "EK.76-77",
"B44.108-110" => "EK.79-81",
"B44.111-112" => "EK.85-86",
"B44.113-117" => "EK.88-92",
"B44.118" => "EK.95",
"B44.119-120" => "EK.97-98",
"B44.121-123" => "EK.101-103",
"B44.124" => "EL.02",
"B44.125-126" => "EL.04-05",
"B44.127-128" => "EL.07-08",
"B44.129-132" => "EL.11-14",
"B44.133" => "EL.18",
"B44.134-136" => "EL.20-22",
"B44.137" => "EL.25",
"B44.138-139" => "EL.28-29",
"B44.140" => "EL.32",
"B44.141-142" => "EL.34-35",
"B44.143-145" => "EL.44-46",
"B44.146-147" => "EL.59-60",
"B44.148-149" => "EL.65-66",
"B44.150-152" => "EL.68-70",
"B44.153" => "EL.72",
"B44.154-156" => "EL.75-77",
"B44.157-158" => "EL.79-80",
"B44.159" => "EL.82",
"B44.160" => "EL.88",
"B44.161" => "EL.92",
"B44.162-163" => "EL.94-95",
"B44.164-165" => "EL.97-98",
"B44.166" => "EL.100",
"B44.167-168" => "EM.01-02",
"B44.169-171" => "EM.09-11",
"B44.172-174" => "EM.13-15",
"B44.175" => "EM.20",
"B44.176" => "EM.22",
"B44.177-178" => "EM.27-28",
"B44.179-180" => "EM.31-32",
"B44.181" => "EM.42",
"B44.182-185" => "EM.34-37",
"B44.186-187" => "EM.39-40",
"B44.188" => "EM.46",
"B44.189-193" => "EM.48-52",
"B44.194" => "EM.55",
"B44.195" => "EM.57",
"B44.196-197" => "EM.60-61",
"B44.198" => "EM.63",
"B44.199-200" => "EM.65-66",    
}
#the next hash picks up at B44.900s and ends at B45.1000
B44to45hash={
'B44.901-78' => 'AY.001-078',
'B44.979-95' => 'AY.080-96',
'B44.996-98' => 'AY.098-100',
'B44.999' => 'AZ.001',
'B45.000-81' => 'AZ.002-83',
'B45.082' => 'AZ.085',
'B45.083' => 'AZ.084',
'B45.084-98' => 'AZ.086-100',
'B45.099-198' => 'BB.001-100',
'B45.199-261' => 'BA.001-63',
'B45.262' => 'BA.071',
'B45.263' => 'BA.069',
'B45.264' => 'BA.070',       ### Due to conflicts within the BA classifications, the following classifications
'B45.265' => 'BA.064',#BA.059  # were reclassified and have their old baly classification listed next to them
'B45.266' => 'BA.066',#BA.061
'B45.267' => 'BA.065',#BA.060
'B45.268' => 'BA.072',
'B45.269' => 'BA.067',#BA.069
'B45.270' => 'BA.068',#BA.070
#####################################################################
# B45.200s are the first well documented classification change in Baly Project History!
# If you are looking for more info on the earlier state of the collection and the
# rationale for modifications, take a look at the documentation file in the drive
#####################################################################
'B45.271-277' => 'BA.073-79',
'B45.278' => 'BA.093',
'B45.279' => 'BA.092',
'B45.280' => 'BA.091',
'B45.281' => 'BA.090',
'B45.282' => 'BA.089',
'B45.283' => 'BA.088',
'B45.284' => 'BA.087',
'B45.285' => 'BA.086',
'B45.286' => 'BA.094',
'B45.287' => 'BA.084',
'B45.288' => 'BA.083',
'B45.289' => 'BA.082',
'B45.290' => 'BA.081',
'B45.291' => 'BA.080',
'B45.292-389' => 'BC.001-98',
'B45.390-478' => 'BD.001-89',
'B45.479' => 'BD.091',
'B45.480' => 'BD.090',
'B45.481-489' => 'BD.092-100',
'B45.490-589' => 'BE.001-100',
'B45.590-661' => 'BF.001-72',
'B45.662' => 'BF.074',
'B45.663' => 'BF.073',
'B45.664-689' => 'BF.075-100',
'B45.690-789' => 'BG.001-100',
'B45.790-889' => 'BH.001-100',
'B45.890-984' => 'BI.001-95',
'B45.985-999' => 'BJ.001-15'
}
B46hash={
"B46.000-084" => "BJ.016-100",
"B46.085-174" => "BK.001-90",
"B46.175" => "BK.092",
"B46.176" => "BK.091",
"B46.177-181" => "BK.093-97",
"B46.182-280" => "BL.001-99",
"B46.281"=>"BL.100", #this slide is also categorized BL.099, so it has been changed to 100
"B46.282-353" => "BM.001-72",
"B46.354" => "BM.074",
"B46.355" => "BM.073",
"B46.356-381" => "BM.075-100",
"B46.382-481" => "BN.001-100",
"B46.482-556" => "BQ.001-75",
#the following have no Baly numbers, so we use the invented group FL
"B46.557-561" => "FL.101-105",
#and these have been assigned the unnumbered group GB
"B46.562-656" => "GB.001-95", #These may get changed to BR, 
# since they certainly seem to be placed here with that in mind, but we'll see
"B46.657-756" => "BS.001-100",
"B46.757-856" => "BT.001-100",
"B46.857-933" => "BU.001-77", #there is doubt as to the origin of this collection
"B46.934-999" => "BV.001-66"
}
B47hash={
'B47.000-024' => 'BV.067-091',
#the next slide is totally unaccounted for, so it gets XE (does not exist)
'B47.025' => "XE.001",
'B47.026-76' => 'BW.001-51',#BW slides dont have numbers, so they are artificially numbered here according to the VRC order.
'B47.077' => 'EJB.001',  # The numbers on the EJB slides are invented, 
'B47.078' => 'EJB.002',  # and may need to be changed if more are found
'B47.079-91' => 'BW.54-66',
'B47.092' => 'CY.088',
'B47.093' => 'BW.067',
'B47.094' => 'BW.068',
'B47.095' => 'CY.085',
'B47.096' => 'CY.089',
'B47.097' => 'BW.069',
'B47.098' => 'CY.091',
'B47.099-105' => 'BW.070-76',
'B47.106-110' => 'CY.094-98',
'B47.111' => 'CY.100',
'B47.112-118' => 'BW.77-83',
'B47.119-200' => 'BX.001-82',
'B47.201-218' => 'BX.083-100',
'B47.219-300' => 'BY.001-82',  
'B47.301-316' => 'BY.083-98',
'B47.317' => 'BY.100',
'B47.318' => 'BY.099',
'B47.319-418' => 'BZ.001-100',
'B47.419-518' => 'CA.001-100',
'B47.519-618' => 'CB.001-100',
'B47.619-718' => 'CC.001-100',
'B47.719-811' => 'CD.001-93',
'B47.812-817' => 'CD.095-100',
'B47.818-864' => 'CE.001-47',
'B47.865' => 'CE.049',
'B47.866' => 'CE.050',
'B47.867-890' => 'CE.052-75',
'B47.891' => 'CE.077',
'B47.892-902' => 'CE.079-89',
'B47.903-912' => 'CE.091-100',

#####################################################
#The following slides have no baly numbers. I suggest
# the alphanumeric 'FL' to signal slides that have VRC
# numbers but not baly ones. If this conflicts with a
# decision down the road, fix it here.
'B47.913-1000' => 'FL.001-88',
}
B48to49hash={
'B48.001-12' => 'FL.089-100',
'B48.013-108' => 'CG.001-96', #the first 70 or so are labelled CO, the rest with no baly num. Labelled as CG in the index though
'B48.109-112' => 'FL.101-104', #these ones used to belong to Z but were not put elsewhere after being replaced. They were only reassigned vrc numbers, possibly concurrent with reclassification.
'B48.113-212' => 'CH.001-100',
'B48.213-312' => 'CI.001-100',
'B48.313-412' => 'CJ.001-100',
'B48.413-512' => 'CK.001-100',
'B48.513-612' => 'CL.001-100',
'B48.613-712' => 'CM.001-100',
'B48.713-783' => 'CN.001-71',
'B48.784-883' => 'CO.001-100',
'B48.884-981' => 'CP.001-98', #CP.059 appears twice, so one was changed. This is recorded in the documentation file in the drive
'B48.982-999' => 'CQ.001-18',
'B49.000' => 'CQ.019',
'B49.001-22' => 'CQ.020-41',
'B49.023' => 'CQ.044',
'B49.024' => 'CQ.043',
'B49.025' => 'CQ.042',
'B49.026-81' => 'CQ.045-100',
'B49.082-181' => 'CR.001-100',
'B49.182-281' => 'CS.001-100',
'B49.282-381' => 'CT.001-100',
}

=begin #testing

load 'prettyCommonFunctions.rb'
rtnarr=Array.new
B48to49hash.values.each do |i|
    primus=i.split(".")[0]
    if primus.length < 3
        puts primus
        frst=generateSortingNumbers [primus+'.001']
    end
    unless rtnarr.include? frst
        rtnarr.push frst
    end
end 
rtnarr.each do |el|
    print(el.to_s+',')
end

=end