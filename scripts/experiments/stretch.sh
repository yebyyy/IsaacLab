#!/bin/bash
#SBATCH --job-name=convert_mjcf
#SBATCH --output=slurm_logs/isaaclab/mjcf-%j.out
#SBATCH --error=slurm_logs/isaaclab/mjcf-%j.err
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

CMD="scripts/tools/convert_mjcf.py \
    /workspace/isaaclab/assets/robots/mujoco_menagerie/hello_robot_stretch/stretch.xml \
    /workspace/isaaclab/assets/robots/stretch2.usd \
    --make-instanceable \
    --headless"
# /srv/flash1/xye87/spring2026/IsaacLab/assets/robots/mujoco_menagerie/hello_robot_stretch/stretch.xml


bash /srv/flash1/xye87/spring2026/IsaacLab/docker/cluster/run_job.sh "$CMD"