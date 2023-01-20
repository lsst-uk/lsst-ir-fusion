import sys
from desc.gen3_workflow import ParslGraph

#parsl_graph = '/rds/project/rds-rPTGgs6He74/ras81/lsst-ir-fusion/dmu4/dmu4_VIDEO/slurm/submit/u/ir-shir1/DRP/singleFrame/20220218T134033Z/parsl_graph_config.pickle'
parsl_graph=sys.argv[1]
print('Input: ',parsl_graph)


parsl_config = dict(retries=1, monitoring=True, executor='WorkQueue',
                    log_level='logging.DEBUG',
                    provider='Local', nodes_per_block=31,
                    worker_options="--memory=160000"
)

graph = ParslGraph.restore(parsl_graph, parsl_config=parsl_config)

# Check if we are in an interactive shell, if not, then set block=True.
block = not sys.__stdin__.isatty()
print('Running graph with block={}'.format(block), flush=True)
print(graph.status(), flush=True)
print("Parsl graph status:", flush=True)
graph.status()
print("Status ran.", flush=True)
graph.run(block=block)
print('Completed', flush=True)
