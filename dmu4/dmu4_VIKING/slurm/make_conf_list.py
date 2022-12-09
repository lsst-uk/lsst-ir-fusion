#Hack script to get list of images with a confidence while they work on ticket https://jira.lsstcorp.org/browse/DM-36962

import glob

visit_list=glob.glob('/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201/data/confidence/viking/confidence/*/*/*.fit')
visits=[int(t.split('_')[-4]) for t in visit_list]

images=glob.glob('/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201/data/VIRCAM/raw/viking/raw/*/*/*.fit')
images=[int(t.split('_')[-5]) for t in images]

visits=list(set(images)-set(visits))

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
  butlerConfig: /home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201/data/butler.yaml
  inCollection: confidence/viking,VIRCAM/raw/viking,refcats/viking,VIRCAM/calib
  dataQuery: "band in ('Z','Y','J','H','K') AND visit NOT IN ({})"


parsl_config:
  retries: 0
  monitoring: true
  executor: WorkQueue
  provider: Local
  nodes_per_block: 31
  worker_options: "--memory=160000"
"""

f.write(text)

f.write(end.format(','.join([str(t) for t in visits])))

f.close()
