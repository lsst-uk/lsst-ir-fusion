#Very simple script to open dict of jobs and return job values for given integer job id

import sys
import os
import json

job_num = sys.argv[1]


#dateObs=varArray[0]
#numObs=varArray[1]
#filter=varArray[2]
#tracts=varArray[3]

jobs = json.loads(open(sys.argv[2],'r').read())

def main():
    """Take the array job id and print the job details as a list
    """
    
    #sys.stdout.write(jobs[int(job_num)][0])
    #sys.stdout.write(jobs[int(job_num)][1])
    #os.environ["numObs"] = jobs[job_num][0]
    #os.environ["dateObs"] = jobs[job_num][1]    
    print(
        jobs[job_num][0],
        jobs[job_num][1],
       # jobs[job_num][2],
       # jobs[job_num][3],
    )
    return None

if __name__ == "__main__":
    main()

