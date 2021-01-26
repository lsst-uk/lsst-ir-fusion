'''
Override the default calibrate config parameters. This is mainly concerned with setting 
the reference catalogue and colour terms for its use. Perhaps we can also tinker with 
values here to increase fraction of ccds that pass calibration.
'''
import os.path
ObsConfigDir = os.path.dirname(__file__)

#config.doPhotoCal = False #False # Needs a cal_ref_cat
#config.doAstrometry = False # Needs reference catalogue ingested
# Demand astrometry and photoCal succeed
#config.requireAstrometry = True
#config.requirePhotoCal = True

# Reference catalogs
#The following was copied from obs_subaru and manages conflicts between gen2 and gen3
ref_cat = "ps1_pv3_3pi_20170110_vhs_vista" #_vhs_vista, _video_vista, or _2mass
for refObjLoader in (config.astromRefObjLoader,
                     config.photoRefObjLoader,
                     ):
    refObjLoader.load(os.path.join(ObsConfigDir, "filterMap.py"))
    # This is the Gen2 configuration option.
    refObjLoader.ref_dataset_name = ref_cat

# These are the Gen3 configuration options for reference catalog name.
config.connections.photoRefCat = ref_cat
config.connections.astromRefCat = ref_cat
# These are gen2?:
config.photoCal.applyColorTerms=True
config.photoCal.photoCatName=ref_cat
config.photoCal.match.matchRadius=1.0
config.photoCal.match.sourceSelection.doFlags=False
# Apply unresolved limitation?
config.photoCal.match.sourceSelection.doUnresolved=False
# List of source flag fields that must NOT be set for a source to be used.
config.photoCal.match.sourceSelection.flags.bad=[
    #'base_PixelFlags_flag_edge', 
    #'base_PixelFlags_flag_interpolated', 
    #'base_PixelFlags_flag_saturated',
]

# Taken from https://github.com/lsst/pipe_tasks/blob/master/python/lsst/pipe/tasks/colorterms.py:
# p' = primary + c0 + c1*(primary - secondary) + c2*(primary - secondary)**2
# VISTA-2MASS colour terms taken from https://arxiv.org/abs/1711.08805 eqn 5-9
# Z_V = J_2 + (0.86 ± 0.08) · (J − Ks)_2
# Y_V = J_2 + (0.46 ± 0.02) · (J − Ks)_2
# J_V = J_2 − (0.031 ± 0.006) · (J − Ks)_2
# H_V = H_2 + (0.015 ± 0.005) · (J − Ks)_2
# Ks_V = Ks_2 − (0.006 ± 0.007) · (J − Ks)_2 = Ks_2 + (0.006 ± 0.007) · (Ks − J)_2

# Alternative J-H term for H from eqn C5
#H_V = H_2 + 0.032 · (J − H)_2 

#VISTA photometric system compared to true Vega:
#VISTA colours of an A0V star
#ZV − JV = 0.004 ± 0.005 (19)
#YV − JV = −0.022 ± 0.003 (20)
#HV − JV = 0.019 ± 0.003 (21)
#KsV − JV = −0.011 ± 0.004 (22)
#Vista AB offsets:
#ZAB − ZV = 0.502 (D2)
#YAB − YV = 0.600 (D3)
#JAB − JV = 0.916 (D4)
#HAB − HV = 1.366 (D5)
#KsAB − KsV = 1.827 (D6)

colorterms = config.photoCal.colorterms
from lsst.pipe.tasks.colorterms import ColortermDict, Colorterm
if 'vista' in ref_cat:
    colorterms.data["ps1*"] = ColortermDict(data={
    #####HSC COLOUR TERMS FROM obs_subaru
    'HSC-G': Colorterm(primary="g", secondary="r", 
    c0=0.00730066, c1=0.06508481, c2=-0.01510570),
    'HSC-R': Colorterm(primary="r", secondary="i", 
    c0=0.00279757, c1=0.02093734, c2=-0.01877566),
    'HSC-I': Colorterm(primary="i", secondary="z", 
    c0=0.00166891, c1=-0.13944659, c2=-0.03034094),
    'HSC-Z': Colorterm(primary="z", secondary="y", 
    c0=-0.00907517, c1=-0.28840221, c2=-0.00316369),
    'HSC-Y': Colorterm(primary="y", secondary="z", 
    c0=-0.00156858, c1=0.14747401, c2=0.02880125),
    'VISTA-Z': Colorterm(primary="z", secondary="y", 
    c0=0.0, c1=-0.0, c2=-0.0),
    'VISTA-Y': Colorterm(primary="y", secondary="z", 
    c0=0.0, c1=0.0, c2=0.0),
    'VISTA-J': Colorterm(primary="j", secondary="y",  
    c0=0.0, c1=0.0, c2=0.0),
    'VISTA-H': Colorterm(primary="h", secondary="y",   
    c0=0.0, c1=0.0, c2=0.0),
    'VISTA-Ks': Colorterm(primary="ks", secondary="y", 
    c0=0.0, c1=0.0, c2=0.0),
})
elif ref_cat.endswith('2mass'):
    colorterms.data["ps1*"] = ColortermDict(data={
    #####HSC COLOUR TERMS FROM obs_subaru
    'HSC-G': Colorterm(primary="g", secondary="r", 
    c0=0.00730066, c1=0.06508481, c2=-0.01510570),
    'HSC-R': Colorterm(primary="r", secondary="i", 
    c0=0.00279757, c1=0.02093734, c2=-0.01877566),
    'HSC-I': Colorterm(primary="i", secondary="z", 
    c0=0.00166891, c1=-0.13944659, c2=-0.03034094),
    'HSC-Z': Colorterm(primary="z", secondary="y", 
    c0=-0.00907517, c1=-0.28840221, c2=-0.00316369),
    'HSC-Y': Colorterm(primary="y", secondary="z", 
    c0=-0.00156858, c1=0.14747401, c2=0.02880125),
    ####2MASS COLOUR TERMS - all from J, Ks - see above
    'VISTA-Z': Colorterm(primary="j", secondary="ks", 
    c0=0.502-0.004, c1=0.86, c2=-0.0),
    'VISTA-Y': Colorterm(primary="j", secondary="ks", 
    c0=0.600+0.022, c1=0.46, c2=0.0),
    'VISTA-J': Colorterm(primary="j", secondary="ks",   
    c0=0.916, c1=0.031, c2=0.0),
    'VISTA-H': Colorterm(primary="h", secondary="j",   
    c0=1.366-0.019, c1=0.032, c2=0.0),
    'VISTA-Ks': Colorterm(primary="ks", secondary="j", 
    c0=1.827+0.011, c1=0.006, c2=0.0), #Sign inverted from form above
})
# For the HSC r2 and i2 filters, use the r and i values from the catalog
# for refObjLoader in (config.calibrate.astromRefObjLoader,
#                      config.calibrate.photoRefObjLoader,
#                      config.charImage.refObjLoader,
#                      ):
#     pass
#    refObjLoader.filterMap['r2'] = 'r'
#    refObjLoader.filterMap['i2'] = 'i'

for i in [
#        'base_GaussianFlux',
#        'base_SdssShape', #base_SdssShape is needed for PSF determination.
        #'base_ScaledApertureFlux',
#        'base_CircularApertureFlux',
        'base_Blendedness',
        #'base_LocalBackground',
        #'base_Jacobian',
        #'base_FPPosition',
        #'base_Variance',
        #'base_InputCount',
        #'base_SkyCoord',
]:
    config.measurement.plugins[i].doMeasure=False
    
    
    
#Astrometry
# Raise an exception if astrometry fails? Ignored if doAstrometry false.
config.requireAstrometry=False #Debateable?

# List of flags which cause a source to be rejected as bad
config.astrometry.sourceSelector['astrometry'].badFlags=[
    'base_PixelFlags_flag_edge', 
    'base_PixelFlags_flag_interpolatedCenter', 
    'base_PixelFlags_flag_saturatedCenter', 
    'base_PixelFlags_flag_crCenter', 
    'base_PixelFlags_flag_bad'
]

config.measurement.load(os.path.join(ObsConfigDir, "apertures.py"))
config.measurement.load(os.path.join(ObsConfigDir, "kron.py"))
config.measurement.load(os.path.join(ObsConfigDir, "hsm.py"))

# Type of source flux; typically one of Ap or Psf
config.astrometry.sourceSelector['astrometry'].sourceFluxType='Ap'

# Minimum allowed signal-to-noise ratio for sources used for matching (in the flux specified by sourceFluxType); <= 0 for no limit
config.astrometry.sourceSelector['astrometry'].minSnr=5.0

# Type of source flux; typically one of Ap or Psf
config.astrometry.sourceSelector['matcher'].sourceFluxType='Ap'

# Minimum allowed signal-to-noise ratio for sources used for matching (in the flux specified by sourceFluxType); <= 0 for no limit
config.astrometry.sourceSelector['matcher'].minSnr=5.0

# Exclude objects that have saturated, interpolated, or edge pixels using PixelFlags. For matchOptimisticB set this to False to recover previous matcher selector behavior.
config.astrometry.sourceSelector['matcher'].excludePixelFlags=False

# specify the minimum psfFlux for good Psf Candidates
config.astrometry.sourceSelector['objectSize'].fluxMin=1000.0