#!/bin/bash

awk -F ',' '{english_name[$1] = $2} {registered[$1] += $4 } { deaths[$1] += $5 } { death_rate[$1] = int((deaths[$1] / registered[$1]) * 1000) } END {for (i in death_rate) print i " (" english_name[i] "): " death_rate[i]}' < <(join -t ',' <(sort province.csv) <(join -t ',' <(sort city_province.csv) <(sort spread.csv) | cut -d ',' -f2- | sort)) | sort -n -r -t ':' -k 2 | head -n 10
