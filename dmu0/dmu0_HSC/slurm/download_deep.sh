#!/bin/bash
wget --user $HSCUSER --password $HSCPASSWORD \
    -P /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst-ir-fusion/dmu0/dmu0_HSC/data/ \
    -r --no-parent -nc  \
    https://hsc-release.mtk.nao.ac.jp/archive/filetree/pdr3_dud/deepCoadd-results/HSC-{G,R,I,Z,Y}/{8282,8283,8284,8523,8524,8525,8765,8766,8767}/
