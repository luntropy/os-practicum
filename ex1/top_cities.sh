#!/bin/bash

sort -n -r -k 2 < <(awk -F ',' '$3~/^[1-9]+[0-9]+[1-9]+/ { print $1 ":", int(($4 / $3) * 1000) }' < <(cat spread.csv)) | head -n 10
