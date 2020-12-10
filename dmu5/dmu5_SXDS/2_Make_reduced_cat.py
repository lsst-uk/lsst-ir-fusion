
from astropy.table import Table, vstack
import astropy.units as u

import lsst.daf.persistence as dafPersist

BUTLER_LOC='../../dmu4/dmu4_SXDS/data'
butler = dafPersist.Butler(inputs='{}/rerun/coaddForcedPhot'.format(BUTLER_LOC))

full_cat = Table()
for f in ['0,5', '0,7', '1,3', '1,5', '1,7', '2,4', '2,6', '2,8', '3,4', 
      '3,6', '3,8', '7,3', '7,6', '7,8', '8,3', '8,6', '8,8', '0,6', '0,8', '1,4', 
      '1,6', '1,8', '2,5', '2,7', '3,3', '3,5', '3,7', '7,2', '7,5', '7,7', 
      '8,2', '8,5', '8,7']: #z_stack_files: #[6:7]
    tract = 8524
    patch = f #str(f[-8:-5])
    print(patch)

    try:
        hsc_zSources = butler.get('deepCoadd_meas', 
            {'filter': 'HSC-Z', 'tract': tract, 'patch': patch})
        hsc_ySources = butler.get('deepCoadd_meas', 
            {'filter': 'HSC-Y', 'tract': tract, 'patch': patch})
        zSources = butler.get('deepCoadd_meas', 
            {'filter': 'VISTA-Z', 'tract': tract, 'patch': patch})
        ySources = butler.get('deepCoadd_meas', 
            {'filter': 'VISTA-Y', 'tract': tract, 'patch': patch})

        hsc_zCoaddCalexp = butler.get('deepCoadd_calexp',  
            {'filter': 'HSC-Z', 'tract': tract, 'patch': patch})
        hsc_zCoaddPhotoCalib = hsc_zCoaddCalexp.getPhotoCalib()
        hsc_yCoaddCalexp = butler.get('deepCoadd_calexp',  
            {'filter': 'HSC-Y', 'tract': tract, 'patch': patch})
        hsc_yCoaddPhotoCalib = hsc_yCoaddCalexp.getPhotoCalib()
        zCoaddCalexp = butler.get('deepCoadd_calexp',  
            {'filter': 'VISTA-Z', 'tract': tract, 'patch': patch})
        zCoaddPhotoCalib = zCoaddCalexp.getPhotoCalib()
        yCoaddCalexp = butler.get('deepCoadd_calexp',  
            {'filter': 'VISTA-Y', 'tract': tract, 'patch': patch})
        yCoaddPhotoCalib = yCoaddCalexp.getPhotoCalib()
    
        cat = Table()
        fMeas_type = 'base_CircularApertureFlux_6_0' #'base_PsfFlux'  
        hsc_zMeasMags = hsc_zCoaddPhotoCalib.instFluxToMagnitude(hsc_zSources, fMeas_type)
        hsc_yMeasMags = hsc_yCoaddPhotoCalib.instFluxToMagnitude(hsc_ySources, fMeas_type)
        zMeasMags = zCoaddPhotoCalib.instFluxToMagnitude(zSources, fMeas_type)
        yMeasMags = yCoaddPhotoCalib.instFluxToMagnitude(ySources, fMeas_type)
 
    
        cat['m_ap60_hsc_z'] = hsc_zMeasMags[:,0]
        cat['merr_ap60_hsc_z'] = hsc_zMeasMags[:,1]
        cat['m_ap60_hsc_y'] = hsc_yMeasMags[:,0]
        cat['merr_ap60_hsc_y'] = hsc_yMeasMags[:,1]
    
        cat['m_ap60_vista_z'] = zMeasMags[:,0]
        cat['merr_ap60_vista_z'] = zMeasMags[:,1]
        cat['m_ap60_vista_y'] = yMeasMags[:,0]
        cat['merr_ap60_vista_y'] = yMeasMags[:,1]
 
    
        fMeas_type = 'base_CircularApertureFlux_9_0' #'base_PsfFlux'  
        hsc_zMeasMags = hsc_zCoaddPhotoCalib.instFluxToMagnitude(hsc_zSources, fMeas_type)
        hsc_yMeasMags = hsc_yCoaddPhotoCalib.instFluxToMagnitude(hsc_ySources, fMeas_type)
        zMeasMags = zCoaddPhotoCalib.instFluxToMagnitude(zSources, fMeas_type)
        yMeasMags = yCoaddPhotoCalib.instFluxToMagnitude(ySources, fMeas_type)

        cat['m_ap90_hsc_z'] = hsc_zMeasMags[:,0]
        cat['merr_ap90_hsc_z'] = hsc_zMeasMags[:,1]
        cat['m_ap90_hsc_y'] = hsc_yMeasMags[:,0]
        cat['merr_ap90_hsc_y'] = hsc_yMeasMags[:,1]
    
        cat['m_ap90_vista_z'] = zMeasMags[:,0]
        cat['merr_ap90_vista_z'] = zMeasMags[:,1]
        cat['m_ap90_vista_y'] = yMeasMags[:,0]
        cat['merr_ap90_vista_y'] = yMeasMags[:,1]

    
        isDeblended = zSources['deblend_nChild'] == 0
        refTable = butler.get('deepCoadd_ref', 
            {'filter': 'VISTA-Ks', 'tract': tract, 'patch': patch})

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
     
        cat['dec'] = zSources['coord_dec']
     
    
        full_cat = vstack([full_cat,cat])
    except:
        print('Patch {} failed'.format(patch))
    
full_cat.write('./data/HSC_z_y_comparison.fits', overwrite=True)