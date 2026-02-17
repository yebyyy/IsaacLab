#!/usr/bin/env bash

# source ~/.bashrc

#==
# Helper functions
#==

setup_directories() {
    # Check and create directories
    for dir in \
        "${CLUSTER_ISAAC_SIM_CACHE_DIR}/cache/kit" \
        "${CLUSTER_ISAAC_SIM_CACHE_DIR}/cache/ov" \
        "${CLUSTER_ISAAC_SIM_CACHE_DIR}/cache/pip" \
        "${CLUSTER_ISAAC_SIM_CACHE_DIR}/cache/glcache" \
        "${CLUSTER_ISAAC_SIM_CACHE_DIR}/cache/computecache" \
        "${CLUSTER_ISAAC_SIM_CACHE_DIR}/logs" \
        "${CLUSTER_ISAAC_SIM_CACHE_DIR}/data" \
        "${CLUSTER_ISAAC_SIM_CACHE_DIR}/documents"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo "Created directory: $dir"
        fi
    done
}


#==
# Main
#==


# get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# load variables to set the Isaac Lab path on the cluster
source $SCRIPT_DIR/.env.cluster
source $SCRIPT_DIR/../.env.base

# make sure that all directories exists in cache directory
setup_directories

# make sure logs directory exists (in the permanent isaaclab directory)
mkdir -p "$CLUSTER_ISAACLAB_DIR/logs"
touch "$CLUSTER_ISAACLAB_DIR/logs/.keep"

# execute command in singularity container
# NOTE: ISAACLAB_PATH is normally set in `isaaclab.sh` but we directly call the isaac-sim python because we sync the entire
# Isaac Lab directory to the compute node and remote the symbolic link to isaac-sim
apptainer exec \
    --no-home --env "ACCEPT_EULA=Y" --env "ISAACSIM_PATH=${DOCKER_ISAACSIM_ROOT_PATH}" --env "ISAACSIM_PYTHON_EXE=${DOCKER_ISAACSIM_PATH}/python.sh" \
    -B $CLUSTER_ISAAC_SIM_CACHE_DIR/cache/kit:${DOCKER_ISAACSIM_ROOT_PATH}/kit/cache:rw \
    -B $CLUSTER_ISAAC_SIM_CACHE_DIR/cache/ov:${DOCKER_USER_HOME}/.cache/ov:rw \
    -B $CLUSTER_ISAAC_SIM_CACHE_DIR/cache/pip:${DOCKER_USER_HOME}/.cache/pip:rw \
    -B $CLUSTER_ISAAC_SIM_CACHE_DIR/cache/glcache:${DOCKER_USER_HOME}/.cache/nvidia/GLCache:rw \
    -B $CLUSTER_ISAAC_SIM_CACHE_DIR/cache/computecache:${DOCKER_USER_HOME}/.nv/ComputeCache:rw \
    -B $CLUSTER_ISAAC_SIM_CACHE_DIR/logs:${DOCKER_USER_HOME}/.nvidia-omniverse/logs:rw \
    -B $CLUSTER_ISAAC_SIM_CACHE_DIR/data:${DOCKER_USER_HOME}/.local/share/ov/data:rw \
    -B $CLUSTER_ISAAC_SIM_CACHE_DIR/documents:${DOCKER_USER_HOME}/Documents:rw \
    -B $CLUSTER_ISAACLAB_DIR:/workspace/isaaclab:rw \
    -B $CLUSTER_ISAACLAB_DIR/logs:/workspace/isaaclab/logs:rw \
    --nv --writable-tmpfs $CLUSTER_SIF_PATH/isaac-lab_2.3.2.sif \
    bash -c "export ISAACLAB_PATH=/workspace/isaaclab && cd /workspace/isaaclab && /isaac-sim/python.sh ${1}"

echo "(run_singularity.py): Return"