# Setup for Bert training in AWS (EKS and HPK)

## EKS
- Kubernetes version: 1.33
- 4 g4dn.4xlarge Nodes
  - 8 cores, 16 vCPUs
  - 64GB RAM
  - Up to 25 Gigabit Bandwidth

## HPK
- Same hardware as EKS
- Apptainer version: 1.1.4
- Slurm version: 24.05.7
- Flanneld version: 0.20.2

## Pytorch Cluster Specification: 2 variations
- (1) 1 Worker, (2) 4 workers (resources per worker):
  - Memory: 16GB
  - CPUs: 4 
  - Threads: 1

## Training details:
- Model: BERT
- Dataset: "Yelp: reviews of restaurants and local businesses"
- Training Samples: 3600
- Evaluation Samples: 400
- Epochs: 3
- Batch Size: 8
- Gradient Accumulation steps: 1

## Changes to HPK from Kubernetes
- Modify `sessiondir max size` from `16` to `32000` (size in MB, from `/etc/apptainer/apptainer.conf`)

## Results

- 1 worker:
  - EKS: `42 minutes` (43,2 + 40,2 + 42,5)
  - HPK: `62 minutes` (64,5 + 59,9 + 61,4) (w/o the usetmp fix)

- 4 workers:
  - EKS: `6,3 minutes` (6,3 + ... + ...)
  - HPK: `5,3 minutes` (5,4 + 5,2 + 5.3) (w/o the usetmp fix)


## With usetmp fix
- 1 worker:
  - EKS: `42 minutes` (43,2 + 40,2 + 42,5)
  - HPK(with usetmp fix): `60 minutes` (60 + 76.8 + 76)

- 4 workers:
  - EKS: `6,3 minutes` (6,3 + ... + ...)
  - HPK(with usetmp fix): `5.4 minutes` (5.4 + 5.6 + ...)


- Accuracy on all runs ~= [0,45 - 0,55]

