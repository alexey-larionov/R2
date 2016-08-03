#!/bin/bash

# skat_pipeline_slurm.sh
# Run skat pipeline for wecare dataset
# Alexey Larionov, 01Aug2016
# Use: sbatch skat_pipeline_slurm.sh job_description.txt

# ---------------------------------------- #
#           sbatch instructions            #
# ---------------------------------------- #

#SBATCH -J skat_pipeline
#SBATCH --time=01:00:00
#SBATCH -A TISCHKOWITZ-SL2
#SBATCH --nodes=1
#SBATCH --exclusive
#SBATCH --mail-type=ALL
#SBATCH --no-requeue
#SBATCH -p sandybridge
##SBATCH --output skat_pipeline.log
#SBATCH --qos=INTR

# Stop on errors
set -e

# Modules section (required, do not remove)
. /etc/profile.d/modules.sh
module purge
module load default-impi
module load gcc/5.2.0
module load boost/1.50.0
module load texlive/2015
module load pandoc/1.15.2.1

# Set initial working folder
cd "${SLURM_SUBMIT_DIR}"

# Report settings
echo "Job id: ${SLURM_JOB_ID}"
echo "Job name: ${SLURM_JOB_NAME}"
echo "Allocated node: $(hostname)"
echo "Initial working folder:"
echo "${SLURM_SUBMIT_DIR}"
echo ""
echo " ------------------ Output ------------------ "
echo ""
echo "Started pipeline: $(date +%d%b%Y_%H:%M:%S)"
echo ""

# Job description file name
job_file="${1}"

#--------------------------------------------------#
#       Read parameters job description file       #
#--------------------------------------------------#

scripts_folder=$(awk '$1=="scripts_folder:" {print $2}' "${job_file}")
project_folder=$(awk '$1=="project_folder:" {print $2}' "${job_file}")
source_data_folder="${project_folder}/source_data"
interim_data_folder="${project_folder}/interim_data"
logs_folder="${project_folder}/logs"
r_libs_folder=$(awk '$1=="r_libs_folder:" {print $2}' "${job_file}")
r_bin_folder=$(awk '$1=="r_bin_folder:" {print $2}' "${job_file}")
r="${r_bin_folder}/R"

#--------------------------------------------------#
#          Report parameters for the job           #
#--------------------------------------------------#

echo "Job settings:"
echo "${scripts_folder}" # e.g. /scratch/medgen/scripts/wecare_skat_08.16/scripts
echo "${project_folder}" #e.g. "/scratch/medgen/users/alexey/wecare_aug2016"
echo "${source_data_folder}"
echo "${interim_data_folder}"
echo "${logs_folder}"
echo "${r_libs_folder}" # e.g. "/scratch/medgen/tools/r/R-3.2.2/lib64/R/library/"
echo "${r_bin_folder}" # e.g. "/scratch/medgen/tools/r/R-3.2.2/bin"
echo "${r}" # e.g. "/scratch/medgen/tools/r/R-3.2.2/bin/R"
echo ""

#--------------------------------------------------#
#                  Read source data                #
#--------------------------------------------------#
# ~ 2hrs

# Progress report
echo "Started reading data: $(date +%d%b%Y_%H:%M:%S)"

#######################
if [ "a" == "b" ]; then
#######################

# R script name
r_script="${scripts_folder}/s01_read_data_feb2016.Rmd"

# Report name
r_script_name=$(basename "${r_script}")
html_report="${logs_folder}/${r_script_name%.Rmd}.html"

# Compile R expression to run (commnds are in single line, separated by semicolon)
r_expressions="library('rmarkdown', lib='"${r_libs_folder}/"'); render('"${r_script}"', params=list(source_data='"${source_data_folder}"', interim_data='"${interim_data_folder}"'), output_file='"${html_report}"')"

# Run R expressions
"${r}" -e "${r_expressions}"

#######################
fi
#######################

# Progress report
echo "Completed reading data: $(date +%d%b%Y_%H:%M:%S)"

#--------------------------------------------------#
#                  Filter variants                 #
#--------------------------------------------------#

# R script name
r_script="${scripts_folder}/s02_filter_variants_feb2016.Rmd"

# Report name
r_script_name=$(basename "${r_script}")
html_report="${logs_folder}/${r_script_name%.Rmd}.html"

# Compile R expression to run (commnds are in single line, separated by semicolon)
r_expressions="library('rmarkdown', lib='"${r_libs_folder}/"'); render('"${r_script}"', params=list(interim_data='"${interim_data_folder}"'), output_file='"${html_report}"')"

# Run R expressions
"${r}" -e "${r_expressions}"

#--------------------------------------------------#

# Completion message
echo "Completed pipeline: $(date +%d%b%Y_%H:%M:%S)"
