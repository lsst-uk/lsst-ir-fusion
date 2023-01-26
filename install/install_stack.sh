#!/bin/bash
#Get latest weekly from https://github.com/lsst/lsst/tags
export weekly='w.2023.02'
mkdir source/$weekly
cd source/$weekly
curl -OL https://raw.githubusercontent.com/lsst/lsst/$weekly/scripts/newinstall.sh



