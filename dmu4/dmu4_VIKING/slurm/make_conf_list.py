#Hack script to get list of images with a confidence while they work on ticket https://jira.lsstcorp.org/browse/DM-36962

import glob

visit_list=glob.glob('/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930/data/viking/confidence/*/*/*.fit')
visits=[int(t.split('_')[-3]) for t in visit_list]

f=open('bpsConfList.yaml','a')

text="""
includeConfigs:
  - ${GEN3_WORKFLOW_DIR}/python/desc/gen3_workflow/etc/bps_drp_baseline.yaml
  - ${GEN3_WORKFLOW_DIR}/examples/bps_DC2-3828-y1_resources.yaml

pipelineYaml: "${OBS_VISTA_DIR}/pipelines/DRP_full.yaml#singleFrame"

project: dev
campaign: quick
computeSite: iris
"""

end="""
payload:
  payloadName: DRP/vikingSingleFrame
  butlerConfig: /home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930/data/butler.yaml
  inCollection: viking,VIRCAM/raw/viking,vikingRefCats,VIRCAM/calib
  dataQuery: "band in ('Z','Y','J','H','K') AND visit IN ({})"


parsl_config:
  retries: 1
  monitoring: true
  executor: WorkQueue
  provider: Local
  nodes_per_block: 31
  worker_options: "--memory=160000"
"""

f.write(text)

f.write(end.format(','.join([str(t) for t in visits])))

f.close()
