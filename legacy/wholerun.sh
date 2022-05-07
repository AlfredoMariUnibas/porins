#!/bin/bash
#SBATCH --job-name=porin_master
#SBATCH --time=02:00:00
#SBATCH --qos=6hours
#SBATCH --output=Master%A_%a.out
#SBATCH --mem=4G

querydir=$1
dbdir=$2

echo "mock" > queries.l
ls "$querydir"* >> queries.l

echo "mock" > db1.l
ls "$dbdir"* >> db1.l

arr=$(wc -l queries.l | awk '{print $1-1}')
echo "array for samples is $arr"
sbatch --array=1-"$arr" multisample.sh "$dbdir"

while true; do
	files=("./"*.post)
	length=${#files[@]}
	if [ "$length" != "$arr" ];
	then
		echo "Number of samples to be screened: $arr .."
		echo "Number of samples screened: $length"
		echo "..still waiting for completion.."
		sleep 180 ## checks the directory every 3 min to see whether the jobs are done
	else
		# modify output
		tail -n +1 *.tsv > All_results.tsv
		rm *.post
		rm *.flag
		break
	fi
done


