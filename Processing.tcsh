rm -f S6.txt
rm -f R1.txt

sdhdf_identify -src S6 uwl*.Tav.hdf > S6.txt
#sdhdf_identify -src R1 uwl*.Tav.hdf > R1.txt

mkdir -p S6_data

foreach file (`cat S6.txt | grep -v -e "ERROR" -e "ATTEMPTING"`)
 \cp $file S6_data
end 

#foreach file (`cat R1.txt | grep -v -e "ERROR" -e "autoFlag" -e  "flagged"`)
 #\cp $file S6_data
#end

\cp S6.txt S6_data
#\cp R1.txt S6_data
\cp time.py S6_data

cd S6_data
rm -f time_data.txt
sdhdf_extractBand -zoom 1664 1668 -zoom 3335 3336 -zoom 1420 1421 -e extract uwl*.Tav.hdf
sdhdf_statistics uwl*.Tav.extract.hdf > time_data.txt
rm -f Matched_pair_1.txt
rm -f join*.lsr.hdf
python time.py
mkdir -p S6_files
set totalLineNumber = `wc -l Matched_pair_1.txt | awk '{print $1}'`

foreach lineNumber (`seq 1 $totalLineNumber`)
  set onFile = `head -$lineNumber Matched_pair_1.txt | tail -1 | awk '{print $1}'`
  \cp $onFile S6_files
  #set offFile = `head -$lineNumber Matched_pair_1.txt | tail -1 | awk '{print $2}'`
  #echo $lineNumber "on = $onFile" "off = $offFile"
  #sdhdf_onoff -subtract -on $onFile -off $offFile -o join_${lineNumber}.hdf
end
cd S6_files
sdhdf_modify -lsr_regrid -e lsr uwl*.Tav.hdf

sdhdf_join -o joint.hdf uwl*.Tav.lsr.hdf

sdhdf_modify -Tav -e Tav joint.hdf

sdhdf_modify -mult2pol 1 0.0000037 0.0000045 -mult2pol 2 0.0000032 0.0000041 -mult2pol 4 0.00000354 0.00000372 -mult2pol 3 0.00000354 0.00000372 -e mult joint.Tav.hdf

rm -f S6.dat

sdhdf_quickdump joint.Tav.mult.hdf > S6.dat