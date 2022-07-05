#!/usr/bin/env bash
#$ -N hail_shell
#$ -cwd
#$ -o /well/lindgren/dpalmer/logs/hail.log
#$ -e /well/lindgren/dpalmer/logs/hail.errors.log
#$ -P lindgren.prjc
#$ -pe shmem 30
#$ -q short.qe@@short.hge
#$ -t 21-21

set -o errexit
set -o nounset

module purge
source /well/lindgren/dpalmer/ukb_utils/bash/qsub_utils.sh
source /well/lindgren/dpalmer/ukb_utils/bash/hail_utils.sh

module load Anaconda3/2020.07
module load java/1.8.0_latest
source activate hail-new
_mem=$( get_hail_memory )
new_spark_dir=/well/lindgren/dpalmer/tmp/spark_test/
export PYSPARK_SUBMIT_ARGS="--conf spark.local.dir=${new_spark_dir} --conf spark.executor.heartbeatInterval=1000000 --conf spark.network.timeout=1000000  --driver-memory ${_mem}g --executor-memory ${_mem}g pyspark-shell"
export PYTHONPATH="${PYTHONPATH-}:/well/lindgren/dpalmer/ukb_utils/python:/well/lindgren/dpalmer:/well/lindgren/dpalmer/ukb_common/src"

# chr=$(get_chr ${SGE_TASK_ID})

export HAIL_TMP_DIR="/well/lindgren/UKBIOBANK/dpalmer"

TRANCHE="200k"

# Inputs:
MT="/well/lindgren/UKBIOBANK/nbaya/wes_${TRANCHE}/ukb_wes_qc/data/filtered/ukb_wes_${TRANCHE}_filtered_chr${chr}.mt"
FINAL_SAMPLE_LIST="/well/lindgren/UKBIOBANK/dpalmer/wes_${TRANCHE}/ukb_wes_qc/data/samples/09_final_qc.keep.BRaVa.sample_list"
FINAL_VARIANT_LIST="/well/lindgren/UKBIOBANK/dpalmer/wes_${TRANCHE}/ukb_wes_qc/data/variants/08_final_qc.pop.keep.variant_list"
SUPERPOPS="/well/lindgren/UKBIOBANK/dpalmer/superpopulation_assignments/superpopulation_labels.tsv"
# Outputs
QC_MT_PREFIX="/well/lindgren/UKBIOBANK/dpalmer/wes_${TRANCHE}/ukb_wes_qc/data/final_mt/10_strict_filtered_chr${chr}"

python 10_create_qc_mt.py ${MT} ${FINAL_SAMPLE_LIST} ${FINAL_VARIANT_LIST} ${SUPERPOPS} ${QC_MT_PREFIX}
print_update "Finished running Hail for chr${chr}" "${SECONDS}"
