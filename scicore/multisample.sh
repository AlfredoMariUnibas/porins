#!/bin/bash
#SBATCH --job-name=porin_multisample
#SBATCH --time=02:00:00
#SBATCH --qos=6hours
#SBATCH --output=multisample%A_%a.out
#SBATCH --mem=4G
readarray -t array < queries.l
export q_id=${array["$SLURM_ARRAY_TASK_ID"]}

db_dir=$1
arrndb=$(wc -l db1.l | awk '{print $1-1}')
echo "array of databases is $arrndb"

echo "Submitting job for $q_id"
sbatch --array=1-"$arrndb" multidb_runner.sh "$q_id"

while true; do
	files=("./"$(basename $q_id .fasta)*.flag)
	length=${#files[@]}
	if [ "$length" != "$arrndb" ];
	then
		echo "Number of databases to be screened: $arrndb .."
		echo "Number of databases screened: $length"
		echo "..still waiting for completion.."
		sleep 180 ## checks the directory every 3 min to see whether the jobs are done
	else
		# modify output
		sed -i 's/[*]/[****]stop[****]/g' $(basename $q_id .fasta)_*.tsv && sed -i 's/# Fields: //g' $(basename $q_id .fasta)_*.tsv && sed -i 's/,/\t/g' $(basename $q_id .fasta)_*.tsv && sed -i '/^#/d' $(basename $q_id .fasta)_*.tsv
		# add filenames as first line of each file and combine files
		tail -n +1 $(basename $q_id .fasta)_*.tsv > $(basename $q_id .fasta)_results.tsv
		touch $(basename $q_id .fasta).post
		break
	fi
done


