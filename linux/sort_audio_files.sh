#!/bin/bash
muz_path="/G_DRIVE/musiques/Travail"
mkdir -p "$muz_path/mp3"
mkdir -p "$muz_path/wma"
mkdir -p "$muz_path/wav"

#find . -name '*.*' -exec sh -c ' a=$(echo "$0" | sed -r "s/([^.]*)\$/\L\1/"); [ "$a" != "$0" ] && mv "$0" "$a" ' {} \;
  
for filename in $muz_path/*.*; do
        format=$(ffprobe "$filename" -show_format 2>/dev/null |
                awk -F"=" '$1 == "format_long_name" {print $2}')
        
        if [ "$format" == "MP2/3 (MPEG audio layer 2/3)" ]; then 
                mv "$filename" "$muz_path/mp3/"
        elif [ "$format" == "ASF (Advanced / Active Streaming Format)" ]; then 
                mv "$filename" "$muz_path/wma/"
        elif [ "$format" == "WAV / WAVE (Waveform Audio)" ]; then 
                mv "$filename" "$muz_path/wma/"
        fi 

        echo "$filename [$format]"
done

