import json
from astropy.table import Table

t = Table.read("../../dmu0/dmu0_ComCam/comcam_deepcoadd.ecsv", format="ascii.ecsv")

# unique tract/patch pairs
pairs = sorted(set(zip(t["tract"], t["patch"])))

job_dict = {str(i): [int(tr), int(pa)] for i, (tr, pa) in enumerate(pairs)}

with open("DP1-patches.json", "w") as f:
    json.dump(job_dict, f)

print("Wrote patches.json with", len(job_dict), "jobs")
