import lsst.meas.algorithms.ingestIndexReferenceTask
assert type(config) == lsst.meas.algorithms.ingestIndexReferenceTask.ConvertReferenceCatalogConfig

import lsst.meas.algorithms.readFitsCatalogTask

# dataset
config.dataset_config.format_version = 1
config.dataset_config.ref_dataset_name = "the_monster_20250219_vista"
config.dataset_config.indexer.name = "HTM"
config.dataset_config.indexer['HTM'].depth = 7
config.n_processes = 1

# FITS reader
config.file_reader.retarget(target=lsst.meas.algorithms.readFitsCatalogTask.ReadFitsCatalogTask,
                            ConfigClass=lsst.meas.algorithms.readFitsCatalogTask.ReadFitsCatalogConfig)
config.file_reader.hdu = 1

# Keep column_map empty because your cleaned files already have PS1-like column names
config.file_reader.column_map = {}

# coords: your cleaned files store RA/Dec in radians
config.ra_name = "coord_ra"
config.dec_name = "coord_dec"
config.ra_err_name = "coord_raErr"
config.dec_err_name = "coord_decErr"
# IMPORTANT: coord_err_unit is in your FITS header as 'rad'
config.coord_err_unit = "rad"

# Use fluxes mapped via flux_column_map (explicit)
config.mag_column_list = ["g", "r", "i", "z", "y", "j", "h", "ks", "y2", "z2"]

# Tell the convert task which FITS columns hold flux values
config.flux_column_map = {
    "g":  "g_flux",
    "r":  "r_flux",
    "i":  "i_flux",
    "z":  "z_flux",
    "y":  "y_flux",
    "j":  "j_flux",
    "h":  "h_flux",
    "ks": "ks_flux",
    "y2": "y2_flux",
    "z2": "z2_flux",
}

# Map band -> error column in FITS
config.mag_err_column_map = {
    "g":  "g_fluxErr",
    "r":  "r_fluxErr",
    "i":  "i_fluxErr",
    "z":  "z_fluxErr",
    "y":  "y_fluxErr",
    "j":  "j_fluxErr",
    "h":  "h_fluxErr",
    "ks": "ks_fluxErr",
    "y2": "y2_fluxErr",
    "z2": "z2_fluxErr",
}

# IDs & motion
config.id_name = "id"
config.pm_ra_name = "pm_ra"
config.pm_dec_name = "pm_dec"
config.pm_ra_err_name = "pm_raErr"
config.pm_dec_err_name = "pm_decErr"
config.pm_scale = 1.0

config.parallax_name = "parallax"
config.parallax_err_name = "parallaxErr"
config.parallax_scale = 1.0

config.epoch_name = "epoch"
config.epoch_format = "mjd"
config.epoch_scale = "tai"

config.is_photometric_name = None
config.is_resolved_name = None
config.is_variable_name = None
