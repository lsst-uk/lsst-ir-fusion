-- Get the 6 pix/ 1 arcsec radius grizy mags for forced and meas catalogues
SELECT 
    f.object_id,
    f.ra,
    f.dec,
    f.tract,
    f.patch,
    f.isprimary,
    f.i_extendedness_value,
    f3.g_apertureflux_10_mag AS g_f_apertureflux_10_mag,
    f3.g_apertureflux_10_magsigma AS g_f_apertureflux_10_magsigma,
    f3.r_apertureflux_10_mag AS r_f_apertureflux_10_mag,
    f3.r_apertureflux_10_magsigma AS r_f_apertureflux_10_magsigma,
    f3.i_apertureflux_10_mag AS i_f_apertureflux_10_mag,
    f3.i_apertureflux_10_magsigma AS i_f_apertureflux_10_magsigma,
    f3.z_apertureflux_10_mag AS z_f_apertureflux_10_mag,
    f3.z_apertureflux_10_magsigma AS z_f_apertureflux_10_magsigma,
    f3.y_apertureflux_10_mag AS y_f_apertureflux_10_mag,
    f3.y_apertureflux_10_magsigma AS y_f_apertureflux_10_magsigma,
    m3.g_apertureflux_10_mag AS g_m_apertureflux_10_mag,
    m3.g_apertureflux_10_magsigma AS g_m_apertureflux_10_magsigma,
    m3.r_apertureflux_10_mag AS r_m_apertureflux_10_mag,
    m3.r_apertureflux_10_magsigma AS r_m_apertureflux_10_magsigma,
    m3.i_apertureflux_10_mag AS i_m_apertureflux_10_mag,
    m3.i_apertureflux_10_magsigma AS i_m_apertureflux_10_magsigma,
    m3.z_apertureflux_10_mag AS z_m_apertureflux_10_mag,
    m3.z_apertureflux_10_magsigma AS z_m_apertureflux_10_magsigma,
    m3.y_apertureflux_10_mag AS y_m_apertureflux_10_mag,
    m3.y_apertureflux_10_magsigma AS y_m_apertureflux_10_magsigma
FROM
    pdr2_dud.forced AS f
    LEFT JOIN pdr2_dud.forced3 AS f3 ON f.object_id = f3.object_id
    LEFT JOIN pdr2_dud.meas3 AS m3 ON f.object_id = m3.object_id
WHERE pdr2_dud.search_sxds(f.object_id)
AND f.isprimary

-- Get the 6 pix/ 2 arcsec radius? diameter? grizy mags for forced and meas catalogues
SELECT 
    f.object_id,
    f.ra,
    f.dec,
    f.tract,
    f.patch,
    f.isprimary,
    f.i_extendedness_value,
    f3.g_apertureflux_20_mag AS g_f_apertureflux_20_mag,
    f3.g_apertureflux_20_magsigma AS g_f_apertureflux_20_magsigma,
    f3.r_apertureflux_20_mag AS r_f_apertureflux_20_mag,
    f3.r_apertureflux_20_magsigma AS r_f_apertureflux_20_magsigma,
    f3.i_apertureflux_20_mag AS i_f_apertureflux_20_mag,
    f3.i_apertureflux_20_magsigma AS i_f_apertureflux_20_magsigma,
    f3.z_apertureflux_20_mag AS z_f_apertureflux_20_mag,
    f3.z_apertureflux_20_magsigma AS z_f_apertureflux_20_magsigma,
    f3.y_apertureflux_20_mag AS y_f_apertureflux_20_mag,
    f3.y_apertureflux_20_magsigma AS y_f_apertureflux_20_magsigma,
    m3.g_apertureflux_20_mag AS g_m_apertureflux_20_mag,
    m3.g_apertureflux_20_magsigma AS g_m_apertureflux_20_magsigma,
    m3.r_apertureflux_20_mag AS r_m_apertureflux_20_mag,
    m3.r_apertureflux_20_magsigma AS r_m_apertureflux_20_magsigma,
    m3.i_apertureflux_20_mag AS i_m_apertureflux_20_mag,
    m3.i_apertureflux_20_magsigma AS i_m_apertureflux_20_magsigma,
    m3.z_apertureflux_20_mag AS z_m_apertureflux_20_mag,
    m3.z_apertureflux_20_magsigma AS z_m_apertureflux_20_magsigma,
    m3.y_apertureflux_20_mag AS y_m_apertureflux_20_mag,
    m3.y_apertureflux_20_magsigma AS y_m_apertureflux_20_magsigma
FROM
    pdr2_dud.forced AS f
    LEFT JOIN pdr2_dud.forced3 AS f3 ON f.object_id = f3.object_id
    LEFT JOIN pdr2_dud.meas3 AS m3 ON f.object_id = m3.object_id
WHERE pdr2_dud.search_sxds(f.object_id)
AND f.isprimary