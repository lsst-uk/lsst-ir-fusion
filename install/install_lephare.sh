#!/bin/bash
#This assumes you have already cloned the code and run the make file using the following locations
export LEPHAREDIR=/home/ir-shir1/rds/rds-iris-ip005/ras81/LEPHARE
export LEPHAREWORK=/home/ir-shir1/rds/rds-iris-ip005/ras81/LEPHAREWORK

export LEPHARECONFIG=../dmu6/dmu6_VIDEO/config/photoz.para 

## read filters
$LEPHAREDIR/source/filter -c $LEPHARECONFIG

## read galaxy templates and then derive the photometry library
$LEPHAREDIR/source/sedtolib -c $LEPHARECONFIG -t G -GAL_SED $LEPHAREDIR/examples/COSMOS_MOD.list  -GAL_LIB LIB_VISTA
$LEPHAREDIR/source/mag_gal -c $LEPHARECONFIG -t G -GAL_LIB_IN LIB_VISTA -GAL_LIB_OUT VISTA_COSMOS_FREE -MOD_EXTINC 18,26,26,33,26,33,26,33 -EXTINC_LAW SMC_prevot.dat,SB_calzetti.dat,SB_calzetti_bump1.dat,SB_calzetti_bump2.dat  -EM_LINES EMP_UV  -EM_DISPERSION 0.5,0.75,1.,1.5,2. -Z_STEP 0.04,0,6

## Do the same for stars and AGN
$LEPHAREDIR/source/sedtolib -c $LEPHARECONFIG -t S -STAR_SED $LEPHAREDIR/examples/STAR_MOD_ALL.list
$LEPHAREDIR/source/mag_gal -c $LEPHARECONFIG -t S -LIB_ASCII YES -STAR_LIB_OUT ALLSTAR_COSMOS 
## AGN models from Salvato 2009
$LEPHAREDIR/source/sedtolib -c $LEPHARECONFIG -t Q -QSO_SED  $LEPHAREDIR/sed/QSO/SALVATO09/AGN_MOD.list
$LEPHAREDIR/source/mag_gal -c $LEPHARECONFIG -t Q -MOD_EXTINC 0,1000  -EB_V 0.,0.1,0.2,0.3 -EXTINC_LAW SB_calzetti.dat -LIB_ASCII NO  -Z_STEP 0.04,0,6
## Don't run an example yet
##$LEPHAREDIR/source/zphota -c $LEPHARECONFIG -CAT_IN ../dmu6/dmu6_VIDEO/data/8524/48/photoz.in -CAT_OUT zphot_short_example.out -PARA_OUT ../dmu6/dmu6_VIDEO/config/output.para -ZPHOTLIB VISTA_COSMOS_FREE,ALLSTAR_COSMOS,QSO_COSMOS  -ADD_EMLINES 0,100 -AUTO_ADAPT YES   -Z_STEP 0.04,0,6

