import glob
calexp_folder='/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930/data/u/ir-shir1/DRP/vhsCoaddDetect/20221209T131239Z/deepCoadd_calexp'
tracts=glob.glob('{}/*'.format(calexp_folder))
tracts=[int(s.split('/')[-1]) for s in tracts]

bpsText="""
includeConfigs:
  - ${GEN3_WORKFLOW_DIR}/python/desc/gen3_workflow/etc/bps_drp_baseline.yaml
  - ${GEN3_WORKFLOW_DIR}/examples/bps_DC2-3828-y1_resources.yaml

pipelineYaml: "${OBS_VISTA_DIR}/pipelines/DRP_full.yaml#multiVisitLater"

pipetask:
  deblend:
    requestMemory: 30000
  writeObjectTable:
    requestMemory: 2000
  transformObjectTable:
    requestMemory: 2000
  consolidateVisitTable:
    requestMemory: 2000

project: dev
campaign: quick
computeSite: iris
"""

bpsEnd="""
payload:
  payloadName: DRP/vhsMultiVisitReduced
  butlerConfig: /home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930/data/butler.yaml
  inCollection: u/ir-shir1/DRP/vhsCoaddDetect/20221209T131239Z,skymaps,hscImports/pdr3_wide_reduced,refcats/vhs_Y
  dataQuery: "skymap='hscPdr2' AND tract in ({FULLTRACTS})"


parsl_config:
  retries: 0
  monitoring: true
  executor: WorkQueue
  provider: Local
  nodes_per_block: 31
  worker_options: "--memory=100000"
"""
patch_sql=[]
full_tracts=[]
tracts_lim=[]
lim=40
for t in tracts:
    patches=glob.glob('{}/{}/*'.format(calexp_folder,t))
    patches=[s.split('/')[-1] for s in patches]
    if len(patches)==81:
        full_tracts.append(str(t))
        continue
    patch_sql.append('(tract={} and patch IN ({}))'.format(t,','.join(patches)))
    if len(patches)>=lim:
        tracts_lim.append(t)
print('{} full tracts out of {}'.format(len(full_tracts),len(tracts)))
print('{} tracts with more than {} patches'.format(len(tracts_lim),lim))
f=open('bpsVISTAPatchesMulti.yaml','w')
f.write(bpsText)
f.write(bpsEnd.format(
    FULLTRACTS=', '.join(full_tracts)
    #PATCHES=' OR '.join(patch_sql)
))
f.close()
