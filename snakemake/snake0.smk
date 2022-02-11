#search all the queries in all the databases, first let's define where to find the queries and where to find the databases

import os
from os import listdir
from os.path import isfile, join
#search for the directory where the snake pipe is
repo_dir = os.path.dirname(os.path.realpath(__file__))

#configfile
import subprocess
confpath = os.path.join(repo_dir, "config/settings.yaml")
configfile: confpath
	
#dbs --> to be sourced from db_dir
db_files = [f for f in listdir(config["db_dir"]) if isfile(join(config["db_dir"], f))]
dbs= sorted(set([s.strip(".faa") for s in db_files]))
print(dbs)
#queries --> to be sourced from q_dir
q_files = [f for f in listdir(config["q_dir"]) if isfile(join(config["q_dir"], f))]
queries= sorted(set([s.strip(".fasta") for s in q_files]))
print(queries)
#raw data path definition
DBD= os.path.abspath(config["db_dir"])
QD= os.path.abspath(config["q_dir"])

#processed data path definition
PROC_DBD=config["processed_db_dir"]
PROC_REP=config["results_dir"]

#os.mkdir(PROC_DBD)
#os.mkdir(PROC_REP)

#defining the outputs
rule all:
    input:
        expand(os.path.join(PROC_DBD,"{db}.dmnd"), db=dbs),
        expand(os.path.join(PROC_REP,"{sample}/{sample}.vs.{db}.matches.tsv"), sample=queries, db=dbs),
        os.path.join(PROC_REP,"collated.results.txt")
#getting the database search going

rule database_formatting:
    threads: workflow.cores * 0.25
    input:
        raw_db=os.path.join(DBD,"{db}.faa")
    output:
        form_db=os.path.join(PROC_DBD,"{db}.dmnd")
    shell:
        "config/diamond makedb --in {input.raw_db} --db {output.form_db}"

rule database_searching:
    threads: workflow.cores * 0.25
    input:
        raw_query=os.path.join(QD,"{sample}.fasta"),
	search_db=os.path.join(PROC_DBD,"{db}.dmnd")
    output:
        matches=os.path.join(PROC_REP,"{sample}/{sample}.vs.{db}.matches.tsv")
    params:
        query_gencode=config["db_search_gencode"],
	p=config["db_search_p"],
	id=config["db_search_id"],
	subject_cover=config["db_search_sub_cover"],
	masking=config["masking"],
	outfmt=config["db_search_outfmt"],
	b=config["db_search_b"],
	max_tar_seqs=config["db_search_max_tar_seqs"]
    shell:
        "config/diamond blastx --query-gencode {params.query_gencode} -d {input.search_db} -q {input.raw_query} -o {output.matches} -p {params.p} --id {params.id} --subject-cover {params.subject_cover} --masking {params.masking}  --outfmt {params.outfmt} qseqid sseqid slen pident scovhsp length mismatch gapopen qstart qend sstart send evalue bitscore qstrand qseq_translated full_sseq -b {params.b} --max-target-seqs {params.max_tar_seqs} --header --sensitive -c1"

rule output_formatter:
    threads: workflow.cores * 1
    input:
        form_db=expand(os.path.join(PROC_DBD,"{db}.dmnd"), db=dbs)
    params:
        dir= config["results_dir"]
    output:
        outtable=os.path.join(PROC_REP,"collated.results.txt")
    conda:
        "config/dependencies/R.yaml"
    shell:
        "Rscript config/dependencies/writer.R {params.dir} {output.outtable}"
