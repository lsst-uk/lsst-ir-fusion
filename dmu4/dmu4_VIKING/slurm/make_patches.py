import glob
calexp_folder='/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201/data/u/ir-shir1/DRP/vikingCoaddDetect/20230110T180302Z/deepCoadd_calexp'
tracts=glob.glob('{}/*'.format(calexp_folder))
tracts=[int(s.split('/')[-1]) for s in tracts]
#print(tracts)
bpsText="""
includeConfigs:
  - ${GEN3_WORKFLOW_DIR}/python/desc/gen3_workflow/etc/bps_drp_baseline.yaml
  - ${GEN3_WORKFLOW_DIR}/examples/bps_DC2-3828-y1_resources.yaml

pipelineYaml: "${OBS_VISTA_DIR}/pipelines/DRP_full.yaml#multiVisitLater"

pipetask:
  deblend:
    requestMemory: 10000
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
  payloadName: DRP/vikingMultiVisit
  butlerConfig: /home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201/data/butler.yaml
  inCollection: u/ir-shir1/DRP/vikingCoaddDetect/20230110T180302Z,skymaps,hscImports/pdr3_wide_full,refcats/viking
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
        #continue
    patch_sql.append('(tract={} and patch IN ({}))'.format(t,','.join(patches)))
    if len(patches)>=lim:
        tracts_lim.append(str(t))
#print(tracts)
# Some tracts are not covered by reference catalogues so are manually removed
#Loop doesn't work because it shifts the later list elements
#for r in tracts:
#    print(r,type(r))
#    if ((r > 10039) and (r< 10107)): # or ((r>9932) and (r<9954)):
#        print('Removing {}'.format(r))
#        tracts.remove(r)
print('{} full tracts out of {}'.format(len(full_tracts),len(tracts)))
print('{} tracts with more than {} patches'.format(len(tracts_lim),lim))
#print(tracts)
tracts_to_run=[str(t) for t in tracts_lim if not ((int(t) > 10039) and (int(t)< 10107))]
#print(tracts)
f=open('bpsVISTAMultiVisit.yaml','w')
f.write(bpsText)
f.write(bpsEnd.format(
    FULLTRACTS=', '.join(tracts_to_run)
    #PATCHES=' OR '.join(patch_sql)
))
f.close()
