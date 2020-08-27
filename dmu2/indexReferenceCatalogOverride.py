from lsst.meas.algorithms.readFitsCatalogTask import ReadFitsCatalogTask
config.file_reader.retarget(ReadFitsCatalogTask)
config.id_name = "id"
config.ra_name = "coord_ra"
config.dec_name = "coord_dec"
config.ra_err_name = "coord_ra_err"
config.dec_err_name = "coord_dec_err"
config.pm_ra_name = "pm_ra"
config.pm_dec_name = "pm_dec"
config.pm_ra_err_name = "pm_ra_err"
config.pm_dec_err_name = "pm_dec_err"
config.epoch_name = "epoch"
config.epoch_format = "mjd"
config.epoch_scale = "tai"
config.column_list = ["g", "r", "i", "z", "y", "j", "h", "k"]
config.err_column_map = {
    "g": "g_err", 
    "r": "r_err", 
    "i": "i_err", 
    "z": "z_err", 
    "y":"y_err",
    "j":"j_err",
    "h":"h_err",
    "k":"k_err",
}
config.extra_col_names = ["parent","footprint"]
