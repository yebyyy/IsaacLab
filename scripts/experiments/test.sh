#!/bin/bash
#SBATCH --job-name=test
#SBATCH --output=slurm_logs/isaaclab/setup-%j.out
#SBATCH --error=slurm_logs/isaaclab/setup-%j.err
#SBATCH --gpus a40:1
#SBATCH --nodes 1
#SBATCH --nodelist=crushinator,dave,dendrite,protocol,sonny,synapse
#SBATCH --cpus-per-task 8
#SBATCH --ntasks-per-node 4
#SBATCH --partition=overcap
#SBATCH --qos=short

source /nethome/xye87/miniforge3/etc/profile.d/conda.sh
conda deactivate
conda activate /srv/flash1/xye87/envs/isaaclab

echo $APPTAINER_TMPDIR

CMD="--task Isaac-Cartpole-v0 --headless --enable-cameras --num_envs 2 --max_iterations 100 --video --video_length 1000"

bash /srv/flash1/xye87/spring2026/IsaacLab/docker/cluster/run_singularity.sh \
    /srv/flash1/xye87/spring2026/IsaacLab \
    isaac-lab_2.3.2 \
    "$CMD"