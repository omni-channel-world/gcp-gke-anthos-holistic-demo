#!/usr/bin/env bash

# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# "---------------------------------------------------------"
# "-                                                       -"
# "-  Helper script to generate terraform variables        -"
# "-  file based on glcoud defaults.                       -"
# "-                                                       -"
# "---------------------------------------------------------"

# Stop immediately if something goes wrong
set -euo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

# This script should be run from directory that contains the terraform directory.
# The purpose is to populate defaults for subsequent terraform commands.

# git is required for this tutorial
command -v git >/dev/null 2>&1 || { \
 echo >&2 "I require git but it's not installed.  Aborting."; exit 1; }

# glcoud is required for this tutorial
command -v gcloud >/dev/null 2>&1 || { \
 echo >&2 "I require gcloud but it's not installed.  Aborting."; exit 1; }


# gcloud config holds values related to your environment. If you already
# defined a default region we will retrieve it and use it
REGION="$(terraform output --state ${ROOT}/../../terraform/terraform.tfstate cluster_location)"
if [[ -z "${REGION}" ]]; then
    echo "The cluster region is pulled from ${ROOT}/../../terraform/terraform.tfstate" 1>&2
    echo "via the 'terraform output cluster_location' command." 1>&2
    echo "Please create a cluster successfully from the root of this repository before" 1>&2
    echo "proceeding." 1>&2
    exit 1;
fi

# gcloud config holds values related to your environment. If you already
# defined a default project we will retrieve it and use it
CLUSTER_NAME="$(terraform output --state ${ROOT}/../../terraform/terraform.tfstate cluster_name)"
if [[ -z "${CLUSTER_NAME}" ]]; then
    echo "The cluster name is pulled from ${ROOT}/../../terraform/terraform.tfstate" 1>&2
    echo "via the 'terraform output cluster_name' command." 1>&2
    echo "Please create a cluster successfully from the root of this repository before" 1>&2
    echo "proceeding." 1>&2
    exit 1;
fi

# gcloud config holds values related to your environment. If you already
# defined a default project we will retrieve it and use it
PROJECT="$(gcloud config get-value core/project)"
if [[ -z "${PROJECT}" ]]; then
    echo "gcloud cli must be configured with a default project." 1>&2
    echo "run 'gcloud config set core/project PROJECT'." 1>&2
    echo "replace 'PROJECT' with the project name." 1>&2
    exit 1;
fi


# Use git to find the top-level directory and confirm
# by looking for the 'terraform' directory
PROJECT_DIR="$(git rev-parse --show-toplevel)"
if [[ -d "$ROOT/terraform" ]]; then
	PROJECT_DIR="$(pwd)"
fi
if [[ -z "${PROJECT_DIR}" ]]; then
    echo "Could not identify project base directory." 1>&2
    echo "Please re-run from a project directory and ensure" 1>&2
    echo "the .git directory exists." 1>&2
    exit 1;
fi


(cd "${PROJECT_DIR}"
TFVARS_FILE="$ROOT/terraform/terraform.tfvars"
# Write out all the values we gathered into a tfvars file so you don't
# have to enter the values manually
cat <<EOF > "${TFVARS_FILE}"
project="${PROJECT}"
region="${REGION}"
cluster_name="${CLUSTER_NAME}"
EOF
)
