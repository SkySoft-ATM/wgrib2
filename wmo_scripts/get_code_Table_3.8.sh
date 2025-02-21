#!/bin/sh
# This script updates wgrib2 with WMO code info.

urlbase="https://github.com/wmo-im/GRIB2"

outfile="../wgrib2/CodeTable_3.8.dat"
if [ -f "$outfile" ]; then mv "$outfile" "$outfile.old"; fi

#---GRIB2 Code Table 3.8: Grid point position
wget -nv "$urlbase/raw/master/GRIB2_CodeFlag_3_8_CodeTable_en.csv" -O- | sed '{
    s/, /# /g
    s/,/;/g
    s/# /, /g
    s/"//g
  }' | env LC_ALL=en_US iconv -c -f UTF8 -t ASCII//TRANSLIT | awk -F";" '
  {
    num=$3; name=$5
    if (num !="" && num !~ "-" && num !~ "Code") {
      printf "case %5d: string=\"%s\"; break;\n",num,name
    }
  }' > "$outfile"

exit
