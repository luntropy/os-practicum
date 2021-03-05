#!/bin/bash

awk -F ',' '{ registered[$2] += $4 } { deaths[$2] += $5 } {death_rate[$2] = int((deaths[$2] / registered[$2]) * 1000) } END { for (i in death_rate) print i ": " death_rate[i] }' < <(join -t ',' <(sort city_province.csv) <(sort spread.csv) | sort -k 2) | sort -n -r -t ':' -k 2 | head -n 10
