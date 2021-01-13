# Enable HSM shapes (unsetup meas_extensions_shapeHSM to disable)
# 'config' is a SourceMeasurementConfig.
import os.path

from lsst.utils import getPackageDir
try:
    config.load(os.path.join(getPackageDir("meas_extensions_shapeHSM"), "config", "enable.py"))
    config.plugins["ext_shapeHSM_HsmShapeRegauss"].deblendNChild = "deblend_nChild"
except Exception as e:
    print("Cannot enable shapeHSM (%s): disabling HSM shape measurements" % (e,))