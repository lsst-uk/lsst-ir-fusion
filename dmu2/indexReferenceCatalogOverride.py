# The name of the output reference catalog dataset.
config.dataset_config.ref_dataset_name = "ps1_pv3_3pi_20170110_vista"

from lsst.meas.algorithms.readFitsCatalogTask import ReadFitsCatalogTask
config.file_reader.retarget(ReadFitsCatalogTask)
config.id_name = "id"
config.ra_name = "coord_ra"
config.dec_name = "coord_dec"
config.ra_err_name = "coord_raErr"
config.dec_err_name = "coord_decErr"
config.coord_err_unit = 'deg'
config.pm_ra_name = "pm_ra"
config.pm_dec_name = "pm_dec"
config.pm_ra_err_name = "pm_raErr"
config.pm_dec_err_name = "pm_decErr"
config.epoch_name = "epoch"
config.epoch_format = "mjd"
config.epoch_scale = "tai"
config.mag_column_list = [
    "g", "r", "i", "z", "y", "z2", "y2", "j", "h", "ks", 
    #"ks", 
]
config.mag_err_column_map = {
    "g": "g_err", 
    "r": "r_err", 
    "i": "i_err", 
    "z": "z_err", 
    "y":"y_err",
    "z2":"z2_err",
    "y2":"y2_err",
    "j":"j_err",
    "h":"h_err",
    "ks":"ks_err",
   # "ks":"ks_err",
}
config.extra_col_names = ["parent","footprint"]
