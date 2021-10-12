"""
Main inputs:
(Change for all fields)

"""
eazypath = '/Users/raphaelshirley/Documents/github/eazy-photoz/src/eazy'
working_folder = '/Users/raphaelshirley/Documents/github/lsst-ir-fusion/dmu6/dmu6_VIDEO/data'
photometry_catalog = 'lsst_ir_fusion_sxds_photoz_input_20211011.fits'
photometry_format = 'fits'

filter_file = 'sxds_filters.res'
translate_file = 'sxds.translate'

zspec_col = 'z_spec'

flux_col = 'flux'
fluxerr_col ='fluxerr'

do_zp = False
do_zp_tests = False
do_subcats = False

do_full = False
do_stellar = False
do_hb = True
do_merge = True

"""
Training parameters

"""
Ncrossval = 1
test_fraction = 0.2

process_outliers = False
correct_extinction = False

"""
Fitting Parameters
(Change only when needed)

"""

# Templates: Any combination of 'eazy', 'swire', 'atlas'
templates = ['eazy', 'atlas', 'cosmos']#, 'swire']#, 'cosmos', 'atlas'] #,'cosmos', 'atlas']  
fitting_mode = ['a', '1', '1']

defaults = ['defaults/zphot.eazy',
            'defaults/zphot.atlas',
            'defaults/zphot.cosmos']
            #'defaults/zphot.eazy',
            #'defaults/zphot.atlas',
            #'defaults/zphot.swire']

stellar_params = 'defaults/zphot.pickles'

additional_errors = [0.0, 0.0, 0.0]
template_error_norm = [1., 1., 1.]
template_error_file = ''
lambda_fit_max = [5., 30., 30.]



"""
Combination Parameters

"""
include_prior = False # Fold in magnitude prior to individual estimates
fbad_prior = 'flat' # 'flat', 'vol' or 'mag'
prior_parameter_path = 'bootes_I_prior_coeff.npz'
prior_fname = 'r_hsc'
prior_colname = 'hsc_r_mag'
alpha_colname = 'hsc_r_mag'


"""
System Parameters
(Specific system only - fixed after installation)

"""

block_size = 1e4
ncpus = 10


