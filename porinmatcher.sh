#!/bin/bash

set -e -o pipefail

N="`basename "$0"`"

mess="Usage: $N [parameters]

## INFOS
     
    -h|--help        Print this message and exit

## INPUTS: [only one of the following options required, either -Q or -G]

    -Q|--qdir        [path] The absolute path to the folder containing the genomes to be queued in. This and the -G option are mutually exclusive
    -G|--qgenomes    [string] The list of genome files, comma separated, to be queued in. This and the -Q option are mutually excl
usive

## GENERAL PARAMETERS: [required]

    -R|--resdir      [path] The absolute path to the folder in which the results will be cumulated
    -T|--taxonomy    [string] A string indicating the taxonomy on which to limit the search, allowed values are exclusively: AC (Acinetobacter), EC (E.coli), ENT (Enterobacter),
				PA (P.aeruginosa), KL (Klebsiella), all (all the previous, the entire database).  

## DATABASE SEARCH PARAMETERS: [optionals]

    -D|--database_dir                [path] The path to the folder containing databases. Please use only in case there is a valid reason not to use the default ones. Default: porins/snakemake/databases/cds
    -dsg|--db_search_gencode         [numeric] Correspondant to --query-gencode in diamond. Default: 11
    -dsp|--db_search_p               [numeric] Correspondant to -p in diamond. Default: 16
    -dsi|--db_search_id              [numeric] Correspondant to --id in diamond. Default: 95
    -dssc|--db_search_sub_cover      [numeric] Correspondant to --subject-cover in diamond. Default: 60
    -dso|--db_search_outfmt          [numeric] Correspondant to --outfmt in diamond. Default: 6
    -dsb|--db_search_b               [numeric] Correspondant to -b in diamond. Default: 6
    -dsm|--db_search_max_tar_seqs    [numeric] Correspondant to --max-target-seqs in diamond. Default: 1
    -dm|--db_masking                 [numeric] Correspondant to --masking in diamond. Default: 0
    
    "

if [ -z "$2" ]; then echo "$mess"; exit 1; fi
if [[ "$1" = "-h" || $1 == '--help' ]]; then echo "$mess"; exit 1; fi

params=""
while [[ $1 =~ ^- ]]; do
        if [[ "$1" = "-Q" || $1 == '--qdir' ]]; then
                qdir="$2"
                params="$params -Q $qdir"
                shift 2
        elif [[ "$1" = "-G" || $1 == '--qgenomes' ]]; then
                gfiles="$2"
                params="$params -c $gfiles"
                shift 2
        elif [[ "$1" = "-R" || $1 == '--resdir' ]]; then
                resdir="$2"
                params="$params -c $resdir"
                shift 2
        elif [[ "$1" = "-T" || $1 == '--taxonomy' ]]; then
                taxonomy="$2"
                params="$params -T $taxonomy"
                shift 2
        elif [[ "$1" = "-D" || $1 == '--database_dir' ]]; then
                dbdir="$2"
                params="$params -D $dbdir"
                shift 2
        elif [[ "$1" = "-dsg" || $1 == '--db_search_gencode' ]]; then
                dsg="$2"
                params="$params -dsg $dsg"
                shift 2
        elif [[ "$1" = "-dsp" || $1 == '--db_search_p' ]]; then
                dsp="$2"
                params="$params -dsp $dsp"
                shift 2
        elif [[ "$1" = "-dsi" || $1 == '--db_search_id' ]]; then
                dsi="$2"
                params="$params -dsi $dsi"
                shift 2
        elif [[ "$1" = "-dssc" || $1 == '--db_search_sub_cover' ]]; then
                dssc="$2"
                params="$params -dssc $dssc"
                shift 2
        elif [[ "$1" = "-dso" || $1 == '--db_search_outfmt' ]]; then
                dso="$2"
                params="$params -dso $dso"
                shift 2
        elif [[ "$1" = "-dsb" || $1 == '--db_search_b' ]]; then
                dsb="$2"
                params="$params -dsb $dsb"
                shift 2
        elif [[ "$1" = "-dsm" || $1 == '--db_search_max_tar_seqs' ]]; then
                dsm="$2"
                params="$params -dsm $dsm"
                shift 2
        elif [[ "$1" = "-dm" || $1 == '--db_masking' ]]; then
                dm="$2"
                params="$params -dm $dm"
                shift 2
        else
        echo "The argument passed is not a viable option: $1
	      Please check porinmatcher -h to view the viable options"
        exit 1
 fi
done

echo "
### Step 0. Initialization: Parsing and checking required parameters.. ###"
#check inputs
if [ -z "$qdir" ];
        then
		if [ -z "$gfiles" ];
		then
                	echo "
	Error: -Q parameter and -G parameter (query directory or query genomes) are missing, with no default. You need to specify a directory of query genomes.
	                Exiting.."
			exit 1
		else
			echo "
	## Query genomes: -G
		The query genomes are set to $gfiles"
			#move the files into a provisional temp dir
			pdir=".tmp_genomedir/"
			mkdir $pdir
			for i in $(echo $gfiles | tr "," "\n")
			do
				cp $i $pdir 
			done
		fi
        else 
		if [ -z "$gfiles" ];
		then
                	echo "
	## Query dir: -Q
		The query directory provided is set to $qdir"
			pdir=$qdir
		else
			echo "
	Error: -Q parameter and -G paramater are specified at the same time, you need to specify either single genomes (-G) or entire folders containing genomes (-Q)"
			exit 1
		fi
fi

if [ -z "$resdir" ];
        then
                echo "
	Error: -R parameter (results directory) is missing, with no default. You need to specify a directory where to store the outputs.
                      Exiting.."
                exit 1
        else
                echo "
	## Results dir: -R
                The output results directory provided is set to $resdir"
fi

if [ -z "$taxonomy" ];
        then
                echo "
	Error: -T parameter (taxonomy specification) is missing, with no default. You need to specify a taxonomy spec among the following: AC,EC,ENT,PA,KL,all.
                      Exiting.."
                exit 1
        elif [[ "$taxonomy" == "AC" || "$taxonomy" == "EC" || "$taxonomy" == "ENT" || "$taxonomy" == "PA" || "$taxonomy" == "KL" || "$taxonomy" == "all" ]];
                then
			echo "
	## Taxonomy: -T
		The taxonomy provided is set to $taxonomy, search will be limited to dbs belonging to this taxon"
	else 
		echo "
	## Taxonomy: -T
		The taxonomy provided ($taxonomy) is none of the allowed values, please revert to one of the following: AC,EC,ENT,PA,KL,all, Exiting.."
		exit 1
fi

echo "### Step 0.1. Initialization: Parsing and checking optional parameters.. ###"

piperoot="/Users/alf/Documents/porinmatcher/por2/porins"
if [ -z "$dbdir" ];
        then
                echo "
	## Database folder: -D  
		The database folder is set to the default: porin/snakemake/databases/cds"
		dbdir=$piperoot/snakemake/databases/cds/
        else
                echo "
	 ## Database folder: -D
		The database folder is set to custom value: $dbdir

	WARNING: you specifically changed the database source, it is suggested to use the default, however, if you know what you are doing, please double check the database format.."
fi

if [ -z "$dsg" ];
        then
                echo "	## db_search_gencode: 
                Applying the default value: 11"
                dsg=11
        else
                echo "
	## db_search_gencode:
                WARNING: Applying the custom value: $dsg"
fi

if [ -z "$dsp" ];
        then
                echo "	## db_search_p:
                Applying the default value: 16"
                dsp=16
        else
                echo "	## db_search_p:
                WARNING: Applying the custom value: $dsp"
fi

if [ -z "$dsi" ];
        then
                echo "	## db_search_id:
                Applying the default value: 95"
                dsi=95
        else
                echo "	## db_search_id:
                WARNING: Applying the custom value: $dsi"
fi

if [ -z "$dssc" ];
        then
                echo "	## db_search_sub_cover:
                Applying the default value: 60"
                dssc=60
        else
                echo "	## db_search_sub_cover:
                WARNING: Applying the custom value: $dssc"
fi

if [ -z "$dso" ];
        then
                echo "	## db_search_outfmt:
                Applying the default value: 6"
                dso=6
        else
                echo "	## db_search_outfmt:
                WARNING: Applying the custom value: $dso"
fi

if [ -z "$dsb" ];
        then
                echo "	## db_search_b:
                Applying the default value: 6"
                dsb=6
        else
                echo "	## db_search_b:
                WARNING: Applying the custom value: $dsb"
fi

if [ -z "$dsm" ];
        then
                echo "	## db_search_max_tar_seqs:
                Applying the default value: 1"
                dsm=1
        else
                echo "	## db_search_max_tar_seqs:
                WARNING: Applying the custom value: $dsm"
fi

if [ -z "$dm" ];
        then
                echo "	## db_masking:
                Applying the default value: 0"
                dm=0
        else
                echo "	## db_masking:
                WARNING: Applying the custom value: $dm"
fi

rand_n=$(echo $RANDOM % 123 | bc)
id="$taxonomy"_"$rand_n"

##writing the settings.yaml for the snakemake to run
mkdir config_"$id"/
echo "
#This run is assigned to the id: $id
#The path to the repo:
repopath: $piperoot
#the initial samples dir and databases dirs:
#database source
db_dir: $dbdir
#genomes ready to be processed
q_dir: $pdir

#intermediate folder for formatted dbs
processed_db_dir: $resdir/.formatted_db/
#result folder
results_dir: $resdir
#taxonomy chosen
taxonomy: $taxonomy

# additional thresholds if needed here below
#db_search def thresholds 
db_search_gencode: $dsg
db_search_p: $dsp
db_search_id: $dsi
db_search_sub_cover: $dssc
masking: $dm
db_search_outfmt: $dso
db_search_b: $dsb
db_search_max_tar_seqs: $dsm

out_file: $resdir/Collated_table.txt
" > config_"$id"/settings.yaml

#run snakemake
snakemake -s $piperoot/snakemake/snake0.smk --use-conda --cores 4

echo "
####################
Assigned unique run ID to: $id
####################
"
