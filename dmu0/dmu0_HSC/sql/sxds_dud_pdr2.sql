-- Get the 6 pix/ 2 arcsec diameter (diameter specified in schema browser) grizy mags for forced and meas catalogues
SELECT 
    f.object_id,
    f.ra,
    f.dec,
    f.tract,
    f.patch,
    f.isprimary,
    f.i_extendedness_value,
    f3.g_apertureflux_20_mag AS g_f_apertureflux_20_mag,
    f3.g_apertureflux_20_magerr AS g_f_apertureflux_20_magerr,
    f3.r_apertureflux_20_mag AS r_f_apertureflux_20_mag,
    f3.r_apertureflux_20_magerr AS r_f_apertureflux_20_magerr,
    f3.i_apertureflux_20_mag AS i_f_apertureflux_20_mag,
    f3.i_apertureflux_20_magerr AS i_f_apertureflux_20_magerr,
    f3.z_apertureflux_20_mag AS z_f_apertureflux_20_mag,
    f3.z_apertureflux_20_magerr AS z_f_apertureflux_20_magerr,
    f3.y_apertureflux_20_mag AS y_f_apertureflux_20_mag,
    f3.y_apertureflux_20_magerr AS y_f_apertureflux_20_magerr,
    m3.g_apertureflux_20_mag AS g_m_apertureflux_20_mag,
    m3.g_apertureflux_20_magerr AS g_m_apertureflux_20_magerr,
    m3.r_apertureflux_20_mag AS r_m_apertureflux_20_mag,
    m3.r_apertureflux_20_magerr AS r_m_apertureflux_20_magerr,
    m3.i_apertureflux_20_mag AS i_m_apertureflux_20_mag,
    m3.i_apertureflux_20_magerr AS i_m_apertureflux_20_magerr,
    m3.z_apertureflux_20_mag AS z_m_apertureflux_20_mag,
    m3.z_apertureflux_20_magerr AS z_m_apertureflux_20_magerr,
    m3.y_apertureflux_20_mag AS y_m_apertureflux_20_mag,
    m3.y_apertureflux_20_magerr AS y_m_apertureflux_20_magerr
FROM
    pdr3_dud.forced AS f
    LEFT JOIN pdr3_dud.forced3 AS f3 ON f.object_id = f3.object_id
    LEFT JOIN pdr3_dud.meas3 AS m3 ON f.object_id = m3.object_id
WHERE f.isprimary
AND boxSearch(coord, 33.0, 38.0, -6.0, -3.0)
