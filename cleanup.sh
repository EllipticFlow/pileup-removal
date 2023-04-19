#!/bin/bash

find . -maxdepth 1 -name "nbdfit*.pdf" -exec rm {} +
find . -maxdepth 1 -name "2DMap_*.pdf" -exec rm {} +
find . -maxdepth 1 -name "2DMap_*.txt" -exec rm {} +
find . -maxdepth 1 -name "mbin_*.txt" -exec rm {} +
find . -maxdepth 1 -name "parameters*.txt" -exec rm {} +
find . -maxdepth 1 -name "all_parameters.txt" -exec rm {} +
