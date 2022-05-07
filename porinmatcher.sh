#!/bin/bash

set -e -o pipefail

N="`basename "$0"`"

mess="Usage: $N [parameters]

## INFOS
     
    -h|--help        Print this message and exit

## GENERAL PARAMETERS: [required]

    -Q|--qdir        [path] The absolute path to the folder containing the genomes to be quered against the database
    -R|--resdir      [path] The absolute path to the folder in which the results will be cumulated
    -T|--taxonomy    [string] A string indicating the taxonomy on which to limit the search.

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
                echo "
	 Error: -Q parameter (query directory) is missing, with no default. You need to specify a directory of query genomes.
	              Exiting.."
		exit 1
        else 
                echo "
	## Query dir: -Q
		The query directory provided is set to $qdir"
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
	Error: -T parameter (taxonomy specification) is missing, with no default. You need to specify a taxonomy spec among the following: .
                      Exiting.."
                exit 1
        else
                echo "
	## Taxonomy: -T
		The taxonomy provided is set to $taxonomy
"
fi

echo "### Step 0.1. Initialzation: Parsing and checking optional parameters.. ###"

piperoot="/Users/alf/Documents/por2"
if [ -z "$dbdir" ];
        then
                echo "
	## Database folder: -D  
		The database folder is set to the default: porin/snakemake/databases/cds"
		dbdir=$piperoot/porins/snakemake/databases/cds/
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

##writing the settings.yaml for the snakemake to run
echo "
#the initial samples dir and databases dirs:
db_dir: $dbdir
q_dir: $qdir

processed_db_dir: $resdir/.formatted_db/
results_dir: $resdir

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
" > settings.yaml


