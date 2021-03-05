#!/bin/bash

sort -n -r -k 2 < <(awk -F ',' '$4~/^[1-9]+[0-9]+[1-9]+/ { print $1 " (" $2 "):", int(($5 / $4) * 1000) }' < <(join -t ',' <(sort city.csv) <(sort spread.csv))) | sort -n -r -t ':' -k 2 | head -n 10
