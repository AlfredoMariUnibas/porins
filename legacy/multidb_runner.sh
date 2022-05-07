#!/bin/bash
#SBATCH --job-name=porin_multidb
#SBATCH --time=04:00:00
#SBATCH --qos=6hours
#SBATCH --output=multidb%A_%a.out
#SBATCH --mem=256G
#modules
#ml Miniconda2/4.3.30
#ml DIAMOND/0.9.6-goolf-1.7.20
#env
#source activate /scicore/home/egliadr/GROUP/projects/PorinLoss/Software/env/porin/

readarray -t array < db1.l
export db_id=${array["$SLURM_ARRAY_TASK_ID"]}
mkdir formatdbs/
echo "db_id is $db_id"
fdb=formatdbs/$(basename $db_id .faa)_form_db
echo "fdb is $fdb"
# database  
Software/diamond makedb --in "$db_id" --db "$fdb" 
query=$1
#  blast 
# https://github.com/bbuchfink/diamond/wiki/3.-Command-line-options   
Software/diamond blastx --query-gencode 11 -d $fdb -q $query -o $(basename $query .fasta)_$(basename $db_id .faa)_matches.tsv -p 16 --id 70 --subject-cover 50 --outfmt 6 qseqid sseqid slen pident scovhsp length mismatch gapopen qstart qend sstart send evalue bitscore qstrand qseq_translated full_sseq -b 6 --max-target-seqs 10 --header --sensitive -c1; 

touch $(basename $query .fasta)_$(basename $db_id .faa).flag

# modify output
#sed -i 's/[*]/[****]stop[****]/g' *.tsv && sed -i 's/# Fields: //g' *.tsv && sed -i 's/,/\t/g' *.tsv && sed -i '/^#/d' *.tsv

# add filenames as first line of each file and combine files
#tail -n +1 *.tsv >results.tsv
