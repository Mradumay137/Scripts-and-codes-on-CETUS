rm -f S10.txt
sdhdf_identify -src S10 uwl*_2.Tav.hdf > S10.txt
rm -f R1.txt
sdhdf_identify -src R1 uwl*_2.Tav.hdf > R1.txt

mkdir -p S10_method2

foreach file (`cat S10.txt | grep -v "ERROR"`)
 \cp $file S10_method2
end

foreach file (`cat R1.txt | grep -v "ERROR"`)
 \cp $file S10_method2
end

cd S10_method2
rm -f uwl*.lsr.hdf
sdhdf_modify -lsr_regrid -e lsr uwl*.hdf

rm -f S10.txt
rm -f R1.txt
sdhdf_identify -src S10 uwl*_2.Tav.lsr.hdf > S10.txt
sdhdf_identify -src R1 uwl*_2.Tav.lsr.hdf > R1.txt

set totalLineNumber1 = `wc -l S10.txt | awk '{print $1}'`
set totalLineNumber2 = `wc -l R1.txt | awk '{print $1}'`

foreach lineNumber (`seq 1 $totalLineNumber1`)
  set onFile = `head -$lineNumber S10.txt | tail -1 | awk '{print $1}'`
  set offFile = `head -$lineNumber R1.txt | tail -1 | awk '{print $1}'`
  echo $lineNumber "on = $onFile" "off = $offFile"
  sdhdf_onoff -subtract  -on $onFile -off $offFile -o joinOHS10_${lineNumber}.hdf
end
sdhdf_join -o jointmet1.hdf joinOH*.hdf

sdhdf_modify -Tav -e Tav jointmet1.hdf
sdhdf_modify -fav 2 -e fav jointmet1.Tav.hdf

sdhdf_calibrate -fluxcal uwl_210911_142647.anitaLines.fluxcal -e calibrateS jointmet1.Tav.fav.hdf

rm -f S10met2.dat
sdhdf_quickdump jointmet1.Tav.fav.calibrateS.hdf > S10met2.dat