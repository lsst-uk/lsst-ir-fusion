# The Gen 3 Workflow

Running the pipeline at scale can not be performed with pipetask run but must instead use the Batch Processing System BPS:

https://pipelines.lsst.io/modules/lsst.ctrl.bps/quickstart.html

Running this using Slurm on CSD3 requires additional installations. Here I will try to include all the key communications I had with Jim Chiang regarding how to install and run this.

Some useful links:

- https://github.com/LSSTDESC/gen3_workflow/tree/master/python/desc/gen3_workflow
- https://github.com/LSSTDESC/gen3_workflow/wiki/Running-Gen-3-workflow-at-Cambridge

On key difference compared to the gen3 runs is that we cannot submit large job arrays to slurm. This would essentially be using multiple parellelisation technologies simultaneously and the timestamped directories cannot handle large numbers in the same second. For this reason we instead need to submit larger single jobs over multiple nodes. Further down there is possibly superior way of doing this.

## Installation
In general we have followed the installation in the link above

Following an issue with segmentation faults we also tried uninstalling zmq and building from scratch using

```Shell
pip install --no-binary :all: zmq
```


## Correspondence with Jim Chiang

### Regarding basic installation and running

The parsl plugin in gen3_workflow is a little less "turn-key" than the HTCondor version.    That's because it uses a pilot job model for running on the slurm queues at places like NERSC.   Instead of just typing bps submit <yaml file> on the command line, one writes an sbatch script and executes the bps submit command within the slurm job.   Here's an example of an sbatch script that I used at NERSC recently:

```Shell
#!/bin/bash
#SBATCH --job-name=sfp_4430_y1
#SBATCH --output=sfp_4430_y1.stdout
#SBATCH --error=sfp_4430_y1.stderr
#SBATCH --nodes=10
#SBATCH --time=15:00:00
#SBATCH --constraint=knl
#SBATCH --qos=regular
#SBATCH --exclusive
#SBATCH --account=m1727

cd /global/cscratch1/sd/descdm/Gen3/Run2.2i/SFP/4430
source ../../setup.sh
bps submit bps_sfp_Y1_4430_visits_part_00.yaml
```

and here are the corresponding bps yaml file contents:

```Shell
includeConfigs:
  - ${GEN3_WORKFLOW_DIR}/python/desc/gen3_workflow/etc/bps_drp_baseline.yaml
  - ${GEN3_WORKFLOW_DIR}/examples/bps_DC2-3828-y1_resources.yaml

pipelineYaml: "${OBS_LSST_DIR}/pipelines/imsim/DRP.yaml#singleFrame"

payload:
  inCollection: LSSTCam-imSim/defaults
  payloadName: sfp_Y1_4430_visits_part_00
  butlerConfig: /global/cfs/cdirs/lsst/production/gen3/DC2/Run2.2i/repo
  dataQuery: "instrument='LSSTCam-imSim' and visit in (2340,8004,8046,12448,12455,12456,12484,13276,13330,32678,159480,159493,159494,162700,167875,169840,174578,174602,177422,177481,179970,181869,181870,181900,181901,181902,181938,181966,181970,182013,183769,183812,183813,183817,183852,183893,184613,185734,185783,187494,187500,187501,187528,187552,187592,187602,189388,189390,190186,190265,190269,190488,190489,190504,190505,191127,191128,191144,191146,191158,191159,191168,191169,191179,191216,191377,191448,191449,192347,192350,193112,193113,193145,193146,193782,193822,193824,193860,193899,193900,194105,196437,197403,197425,197426,199497,199498,199534,199541,200736,200737,200738,200739,200740,200747,200810,200811,204516,204559,204560,204595,204661,204704,206041,206052,206053,206066,206067,207731,207773,207774,207783,207797,207798,207799,208604,208639,208641,209030,209036,209086,209087,209841,209882,209888,211101,211146,211147,211155,211197,211229,211230,211262,211302,211342,211472,211474,211526,211529,212048,212077,212084,212085,212126,212710,212711,212746,218325,219923,219946,219947,219976,220017,226984,226985,226986,227030,227031,227032,227033,227884,227885,227889,227890,227918,227922,227923,235033,235053,235057,237857,238032,238072,238614,238618,238619,238624,242567,242603,242661,243031,243032,244023,244068,246614,246615,248925,250362,250363,250395,250396,250397,252380,252424,254317,254357,254360,254373,254378,256393,261178,261201)"

parsl_config:
  retries: 1
  monitoring: true
  executor: WorkQueue
  provider: Local
  nodes_per_block: 10
  worker_options: "--memory=90000"
```
  
You'll note that nodes_per_block: 10 matches the number of nodes requested in the sbatch script: #SBATCH --nodes=10.  These should agree so that Parsl knows how many nodes it can dispatch work to.   The other important line in the bps yaml file is worker_options: "--memory=90000".  The Cori-KNL nodes at NERSC have 96 GB of memory per node, and if you omit the worker_options line in the parsl_config, Parsl will assume all of that memory is available for processing.   We've found it useful to use --memory=90000 (units in Mb) so that there's a little reserved for Parsl itself and to give a safety factor in case the pipetasks use more memory than anticipated.  I'll note that the memory allocations in ${GEN3_WORKFLOW_DIR}/examples/bps_DC2-3828-y1_resources.yaml are for Y1 WFD processing.  For single frame processing, the memory allocations should be fine, but for coadd and multiband, you will need to adjust the numbers if you are doing coadds deeper than Y1 WFD.
One last item:  The current master branch of gen3_workflow is known to work with weekly w_2021_50 but there have been changes since then that may not be compatible with that branch.


### Regarding large jobs which may need restarting:

Here are some slides of a tutorial I gave to a DESC working group back in November on running gen3 pipelines at NERSC using the parsl plugin:

https://docs.google.com/presentation/d/1EO_UBVhISBrBussCsIvJhNVxSnyfg5z6yIPaz99gA0A/edit#slide=id.gf546f83b40_0_52

On slide 11, it shows how I use the python interface directly to generate the QG and execution butler.  Doing that is essentially these python commands:

```Python
from desc.gen3_workflow import start_pipeline
graph = start_pipeline('bps_sfp.yaml')
```

I usually run that interactively since it uses just a single process, but it could be submitted as a job on a shared queue.  The problem is that it's not always clear how long it will take.    Once you have that graph object, you can find the output collection name generated by bps using

```Python
graph.config['outCollection']
```

With that info, I infer the location of the parsl_graph_config.pickle file and I generate a script to run rest of the workflow, e.g.,

```Shell
$ cat run_pipeline.py
import sys
from desc.gen3_workflow import ParslGraph

parsl_graph = 'submit/u/descdm/sfp_Y1_4430_visits_part_00/20211213T041900Z/parsl_graph_config.pickle'

parsl_config = dict(retries=1, monitoring=True, executor='WorkQueue',
                    provider='Local', nodes_per_block=10,
                    worker_options="--memory=87000")

graph = ParslGraph.restore(parsl_graph, parsl_config=parsl_config)

# Check if we are in an interactive shell, if not, then set block=True.
block = not sys.__stdin__.isatty()
graph.run(block=block)
```


I'd run this script instead of the bps submit command in the sbatch script:

```Shell
#!/bin/bash
#SBATCH --job-name=sfp_4430_y1
#SBATCH --output=sfp_4430_y1.stdout
#SBATCH --error=sfp_4430_y1.stderr
#SBATCH --nodes=10
#SBATCH --time=15:00:00
#SBATCH --constraint=knl
#SBATCH --qos=regular
#SBATCH --exclusive
#SBATCH --account=m1727

cd /global/cscratch1/sd/descdm/Gen3/Run2.2i/SFP/4430
source ../../setup.sh
python run_pipeline.py
```
