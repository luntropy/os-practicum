#!/bin/bash

grep $(grep 'Wuhan' city.csv | cut -f 1 -d ',') spread.csv | cut -f 4 -d ','
