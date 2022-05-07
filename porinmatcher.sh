#!/bin/bash

set -e -o pipefail

N="`basename "$0"`"

mess="Usage: $N [parameters]

## GENERAL PARAMETERS: [required]

    -Q|--qdir        [path] The absolute path to the folder containing the genomes to be quered against the database
    -R|--resdir      [path] The absolute path to the folder in which the results will be cumulated
    -T|--taxonomy    [string] A string indicating the taxonomy on which to limit the search, 

## DATABASE SEARCH PARAMETERS: [optionals]

    -D|--database_dir                [path] The path to the folder containing databases. Please use only in case there is a valid reason not to use the default ones. Default: repo/
    -dsg|--db_search_gencode         [numeric]
    -dsp|--db_search_p               [numeric]
    -dsi|--db_search_id              [numeric]
    -dssc|--db_search_sub_cover      [numeric]
    -dso|--db_search_outfmt          [numeric]
    -dsb|--db_search_b               [numeric]
    -dsm|--db_search_max_tar_seqs    [numeric]
    -dm|--db_masking                 [numeric] 
    
    "

if [ -z "$2" ]; then echo "$mess"; exit 1; fi

params=""
while [[ $1 =~ ^- ]]; do
        if [[ "$1" = "-m" || $1 == '--multidir' ]]; then
                multidir="$2"
                params="$params -m $multidir"
                shift 2
        elif [[ "$1" = "-c" || $1 == '--compare_list' ]]; then
                compare_list="$2"
                params="$params -c $compare_list"
                shift 2
        elif [[ "$1" = "-r" || $1 == '--ref_fusions' ]]; then
                ref_fusions="$2"
                params="$params -r $ref_fusions"
                shift 2
        elif [[ "$1" = "-d" || $1 == '--name_scheme' ]]; then
                name_scheme="$2"
                params="$params -d $name_scheme"
                shift 2
        elif [[ "$1" = "-o" || $1 == '--output' ]]; then
                out="$2"
                params="$params -o $out"
                shift 2
        elif [[ "$1" = "-R" || $1 == '--reporting' ]]; then
                reporting="$2"
                params="$params -R $reporting"
                shift 2
        elif [[ "$1" = "-t" || $1 == '--target' ]]; then
                target="$2"
                params="$params -t $target"
                shift 2
        else
        echo "Did not understand argument: $1"
        exit 1
 fi
done

#check inputs
if [ -z "$multidir" ];
        then
                multidir="FALSE"
                echo "## MULTIDIR:
                        Logical was not specified, interpreting the compare file as a whole (resorting to the default FALSE), all the pipelines requests in the compare list will be pooled together without further distinction"
        elif [ "$multidir" == "FALSE" ]; then
                echo "## MULTIDIR:
                        Logical was specified: FALSE, interpreting the compare file as a whole, all the pipelines requests in the compare list will be pooled together without further distinction"
        elif [ "$multidir" == "TRUE" ]; then
                echo "## MULTIDIR:
                        Logical was specified: TRUE, interpreting the compare file line by line, all the pipelines requests in the compare list will be considered single entries and end up in separated directories"
fi
