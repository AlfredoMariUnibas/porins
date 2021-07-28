#search all the queries in all the databases, first let's define where to find the queries and where to find the databases

from os import listdir
from os.path import isfile, join

#dbs --> to be sourced from db_dir
db_files = [f for f in listdir(config["db_dir"]) if isfile(join(config["db_dir"], f))]
dbs= sorted(set([s.strip(".faa") for s in db_files]))

#queries --> to be sourced from q_dir
q_files = [f for f in listdir(config["q_dir"]) if isfile(join(config["q_dir"], f))]
queries= sorted(set([s.strip(".fasta") for s in q_files]))

DBD= os.path.abspath(config["db_dir"])
QD= os.path.abspath(config["q_dir"])

#clone the necessary files in there
import os
if (os.path.exists(os.path.abspath('./config/'))):
    print("\n Configuration file and dependencies already present, proceeding.. \n")
else:
    print("\n Configuration file and dependencies missing, starting the download from github.. \n")
    os.system('git clone https://github.com/appliedmicrobiologyresearch/covgap/ temp_soft/')
    os.system('mkdir config/')
    os.system('cp -r temp_soft/repo/config/* config/')
    os.system('cp temp_soft/repo/settings.yaml .')
    os.system('rm -rf temp_soft')
    os.system('chmod 775 config/dependencies/*')
configfile: "settings.yaml"

#defining the outputs
rule all:
    input:
        expand("porin_scan_results/{sample}/{sample}.vs.{db}.matches.tsv", sample=queries, db=dbs)

#getting the database search going

rule database_search:

