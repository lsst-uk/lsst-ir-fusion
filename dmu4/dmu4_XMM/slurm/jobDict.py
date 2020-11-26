#Very simple script to open dict of job info and return job values for given 
#integer job id. It is used to pass arguments to command line processes for 
#Slurm array jobs

import sys
import os
import json

job_num = sys.argv[1]

jobs = json.loads(open(sys.argv[2],'r').read())

def main():
    """Take the array job id and print the job details as a list
    """
    for j in jobs[job_num]:
        print(j)
    return None

if __name__ == "__main__":
    main()

