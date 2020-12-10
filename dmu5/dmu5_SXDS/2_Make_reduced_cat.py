
from astropy.table import Table, vstack
import astropy.units as u

import lsst.daf.persistence as dafPersist

BUTLER_LOC='../../dmu4/dmu4_SXDS/data'
butler = dafPersist.Butler(inputs='{}/rerun/coaddForcedPhot'.format(BUTLER_LOC))

full_cat = Table()
for f in ['3,6','3,7','3,8']: #z_stack_files: #[6:7]
    tract = 8524
    patch = f #str(f[-8:-5])
    print(patch)
    #hsc_gSources = butler.get('deepCoadd_meas', {'filter': 'HSC-G', 'tract': tract, 'patch': patch})
    #hsc_rSources = butler.get('deepCoadd_meas', {'filter': 'HSC-R', 'tract': tract, 'patch': patch})
    #hsc_iSources = butler.get('deepCoadd_meas', {'filter': 'HSC-I', 'tract': tract, 'patch': patch})
    hsc_zSources = butler.get('deepCoadd_meas', {'filter': 'HSC-Z', 'tract': tract, 'patch': patch})
    hsc_ySources = butler.get('deepCoadd_meas', {'filter': 'HSC-Y', 'tract': tract, 'patch': patch})
    zSources = butler.get('deepCoadd_meas', {'filter': 'VISTA-Z', 'tract': tract, 'patch': patch})
    ySources = butler.get('deepCoadd_meas', {'filter': 'VISTA-Y', 'tract': tract, 'patch': patch})
    #jSources = butler.get('deepCoadd_meas', {'filter': 'VISTA-J', 'tract': tract, 'patch': patch})
    #hSources = butler.get('deepCoadd_meas', {'filter': 'VISTA-H', 'tract': tract, 'patch': patch})
    #ksSources = butler.get('deepCoadd_meas', {'filter': 'VISTA-Ks', 'tract': tract, 'patch': patch})
    
   # hsc_gCoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': 'HSC-G', 'tract': tract, 'patch': patch})
    #hsc_gCoaddPhotoCalib = hsc_gCoaddCalexp.getPhotoCalib()
    #hsc_rCoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': 'HSC-R', 'tract': tract, 'patch': patch})
    #hsc_rCoaddPhotoCalib = hsc_rCoaddCalexp.getPhotoCalib()
    #hsc_iCoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': 'HSC-I', 'tract': tract, 'patch': patch})
    #hsc_iCoaddPhotoCalib = hsc_iCoaddCalexp.getPhotoCalib()
    hsc_zCoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': 'HSC-Z', 'tract': tract, 'patch': patch})
    hsc_zCoaddPhotoCalib = hsc_zCoaddCalexp.getPhotoCalib()
    hsc_yCoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': 'HSC-Y', 'tract': tract, 'patch': patch})
    hsc_yCoaddPhotoCalib = hsc_yCoaddCalexp.getPhotoCalib()
    zCoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': 'VISTA-Z', 'tract': tract, 'patch': patch})
    zCoaddPhotoCalib = zCoaddCalexp.getPhotoCalib()
    yCoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': 'VISTA-Y', 'tract': tract, 'patch': patch})
    yCoaddPhotoCalib = yCoaddCalexp.getPhotoCalib()
    #jCoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': 'VISTA-J', 'tract': tract, 'patch': patch})
    #jCoaddPhotoCalib = jCoaddCalexp.getPhotoCalib()
    #hCoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': 'VISTA-H', 'tract': tract, 'patch': patch})
    #hCoaddPhotoCalib = hCoaddCalexp.getPhotoCalib()
    #ksCoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': 'VISTA-Ks', 'tract': tract, 'patch': patch})
    #ksCoaddPhotoCalib = ksCoaddCalexp.getPhotoCalib()


    
    
    cat = Table()
    fMeas_type = 'base_CircularApertureFlux_6_0' #'base_PsfFlux' 'base_CircularApertureFlux_2_0'
    #hsc_gMeasMags = hsc_gCoaddPhotoCalib.instFluxToMagnitude(hsc_gSources, fMeas_type)
    #hsc_rMeasMags = hsc_rCoaddPhotoCalib.instFluxToMagnitude(hsc_rSources, fMeas_type)
    #hsc_iMeasMags = hsc_iCoaddPhotoCalib.instFluxToMagnitude(hsc_iSources, fMeas_type)
    hsc_zMeasMags = hsc_zCoaddPhotoCalib.instFluxToMagnitude(hsc_zSources, fMeas_type)
    hsc_yMeasMags = hsc_yCoaddPhotoCalib.instFluxToMagnitude(hsc_ySources, fMeas_type)
    zMeasMags = zCoaddPhotoCalib.instFluxToMagnitude(zSources, fMeas_type)
    yMeasMags = yCoaddPhotoCalib.instFluxToMagnitude(ySources, fMeas_type)
    #jMeasMags = jCoaddPhotoCalib.instFluxToMagnitude(jSources, fMeas_type)
    #hMeasMags = hCoaddPhotoCalib.instFluxToMagnitude(hSources, fMeas_type)
    #ksMeasMags = ksCoaddPhotoCalib.instFluxToMagnitude(ksSources, fMeas_type)

    #cat['m_ap60_hsc_g'] = hsc_gMeasMags[:,0]
    #cat['merr_ap60_hsc_g'] = hsc_gMeasMags[:,1]
    #cat['m_ap60_hsc_r'] = hsc_rMeasMags[:,0]
    #cat['merr_ap60_hsc_r'] = hsc_rMeasMags[:,1]
    #cat['m_ap60_hsc_i'] = hsc_iMeasMags[:,0]
    #cat['merr_ap60_hsc_i'] = hsc_iMeasMags[:,1]
    cat['m_ap60_hsc_z'] = hsc_zMeasMags[:,0]
    cat['merr_ap60_hsc_z'] = hsc_zMeasMags[:,1]
    cat['m_ap60_hsc_y'] = hsc_yMeasMags[:,0]
    cat['merr_ap60_hsc_y'] = hsc_yMeasMags[:,1]
    
    cat['m_ap60_vista_z'] = zMeasMags[:,0]
    cat['merr_ap60_vista_z'] = zMeasMags[:,1]
    cat['m_ap60_vista_y'] = yMeasMags[:,0]
    cat['merr_ap60_vista_y'] = yMeasMags[:,1]
    #cat['m_ap60_vista_j'] = jMeasMags[:,0]
    #cat['merr_ap60_vista_j'] = jMeasMags[:,1]
    #cat['m_ap60_vista_h'] = hMeasMags[:,0]
    #cat['merr_ap60_vista_h'] = hMeasMags[:,1]
    #cat['m_ap60_vista_ks'] = ksMeasMags[:,0]
    #cat['merr_ap60_vista_ks'] = ksMeasMags[:,1]
    
    fMeas_type = 'base_CircularApertureFlux_9_0' #'base_PsfFlux' 'base_CircularApertureFlux_2_0'
    #hsc_gMeasMags = hsc_gCoaddPhotoCalib.instFluxToMagnitude(hsc_gSources, fMeas_type)
    #hsc_rMeasMags = hsc_rCoaddPhotoCalib.instFluxToMagnitude(hsc_rSources, fMeas_type)
    #hsc_iMeasMags = hsc_iCoaddPhotoCalib.instFluxToMagnitude(hsc_iSources, fMeas_type)
    hsc_zMeasMags = hsc_zCoaddPhotoCalib.instFluxToMagnitude(hsc_zSources, fMeas_type)
    hsc_yMeasMags = hsc_yCoaddPhotoCalib.instFluxToMagnitude(hsc_ySources, fMeas_type)
    zMeasMags = zCoaddPhotoCalib.instFluxToMagnitude(zSources, fMeas_type)
    yMeasMags = yCoaddPhotoCalib.instFluxToMagnitude(ySources, fMeas_type)
    #jMeasMags = jCoaddPhotoCalib.instFluxToMagnitude(jSources, fMeas_type)
    #hMeasMags = hCoaddPhotoCalib.instFluxToMagnitude(hSources, fMeas_type)
    #ksMeasMags = ksCoaddPhotoCalib.instFluxToMagnitude(ksSources, fMeas_type)

    #cat['m_ap90_hsc_g'] = hsc_gMeasMags[:,0]
    #cat['merr_ap90_hsc_g'] = hsc_gMeasMags[:,1]
    #cat['m_ap90_hsc_r'] = hsc_rMeasMags[:,0]
    #cat['merr_ap90_hsc_r'] = hsc_rMeasMags[:,1]
    #cat['m_ap90_hsc_i'] = hsc_iMeasMags[:,0]
    #cat['merr_ap90_hsc_i'] = hsc_iMeasMags[:,1]
    cat['m_ap90_hsc_z'] = hsc_zMeasMags[:,0]
    cat['merr_ap90_hsc_z'] = hsc_zMeasMags[:,1]
    cat['m_ap90_hsc_y'] = hsc_yMeasMags[:,0]
    cat['merr_ap90_hsc_y'] = hsc_yMeasMags[:,1]
    
    cat['m_ap90_vista_z'] = zMeasMags[:,0]
    cat['merr_ap90_vista_z'] = zMeasMags[:,1]
    cat['m_ap90_vista_y'] = yMeasMags[:,0]
    cat['merr_ap90_vista_y'] = yMeasMags[:,1]
    #cat['m_ap90_vista_j'] = jMeasMags[:,0]
    #cat['merr_ap90_vista_j'] = jMeasMags[:,1]
    #cat['m_ap90_vista_h'] = hMeasMags[:,0]
    #cat['merr_ap90_vista_h'] = hMeasMags[:,1]
    ##cat['m_ap90_vista_ks'] = ksMeasMags[:,0]
    #cat['merr_ap90_vista_ks'] = ksMeasMags[:,1]

    
    isDeblended = zSources['deblend_nChild'] == 0
    refTable = butler.get('deepCoadd_ref', 
        {'filter': 'VISTA-Ks', 'tract': tract, 'patch': patch})
    #refTable
    inInnerRegions = refTable['detect_isPatchInner'] & refTable['detect_isTractInner']
    isSkyObject = refTable['merge_peak_sky']
    isPrimary = refTable['detect_isPrimary']
    isStellar = refTable['base_ClassificationExtendedness_value'] < 1.

    zSources.getSchema().extract('{}_*'.format(fMeas_type))
    isGoodFlux = ~zSources['{}_flag'.format(fMeas_type)]
    
    cat['isDeblended'] = isDeblended
    cat['inInnerRegions'] = inInnerRegions
    cat['isSkyObject'] = isSkyObject
    cat['isPrimary'] = isPrimary
    cat['isStellar'] = isStellar
    cat['isGoodFlux'] = isGoodFlux
    selected = isPrimary & isGoodFlux & inInnerRegions & isStellar  
    cat['flag'] = selected
                                                     

                

    cat['ra'] = zSources['coord_ra']
    #cat['ra'] =ksMeasSources['coord_ra']
    cat['dec'] = zSources['coord_dec']
    #cat['dec'] = ksMeasSources['coord_dec']
    
    full_cat = vstack([full_cat,cat])
    
full_cat.write('./data/HSC_z_y_comparison.fits', overwrite=True)