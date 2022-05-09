#!/bin/bash
# -*- coding: utf-8 -*-

wget https://github.com/kbarbary/sfddata/archive/master.tar.gz
tar xf master.tar.gz
mkdir -p data/sfd_data
mv sfddata-master data/sfd_data
rm -f master.tar.gz
