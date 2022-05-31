# PorinMatcher
PorinMatcher performs basic blast search and reporting of intact and partial porin sequences from genome assemblies against an up-to-date and curated database.
### Installation
Main requirements:
- conda v4.9 or higher
- git v2.23 or higher

After making sure both git and conda are in place, the installation of porinmatcher is straight-forward:

```
$ git clone https://github.com/AlfredoMariUnibas/porins path/to/PorinMatcher
$ cd path/to/PorinMatcher/install/

## for installation on mac os
$ bash installer.sh mac 

## for installation in linux
$ bash installer.sh linux
```

After this, make sure to restart your shell and test the correct installation by typing from anywhere in your laptop:

`$ porinmatcher --help`

## Running porinmatcher


Usage: porinmatcher [parameters]

### EXAMPLE

porinmatcher -t 8 -R res10 -T EC -Q path/toPorinMatcher/snakemake/databases/examples/queries

### INFOS

    -h|--help        Print this message and exit

### INPUTS: [only one of the following options required, either -Q or -G]

    -Q|--qdir        [path] The absolute path to the folder containing the genomes to be queued in. This and the -G option are mutually exclusive
    -G|--qgenomes    [string] The list of genome files, comma separated, to be queued in. This and the -Q option are mutually exclusive

### GENERAL PARAMETERS: [required]

    -R|--resdir      [path] The absolute path to the folder in which the results will be cumulated
    -T|--taxonomy    [string] A string indicating the taxonomy on which to limit the search, allowed values are exclusively: AC (Acinetobacter), EC (E.coli), ENT (Enterobacter),
				PA (P.aeruginosa), KL (Klebsiella), all (all the previous, the entire database).

### TECHNICAL PARAMETERS: [optional]

    -t|--threads     [numeric] The number of threads to be used in the parallelisation of genome_vs_databse search: Default 4

### DATABASE SEARCH PARAMETERS: [optional]

    -D|--database_dir                [path] The path to the folder containing databases. Please use only in case there is a valid reason not to use the default ones. Default: porins/snakemake/databases/cds
    -dsg|--db_search_gencode         [numeric] Correspondant to --query-gencode in diamond. Default: 11
    -dsp|--db_search_p               [numeric] Correspondant to -p in diamond. Default: 16
    -dsi|--db_search_id              [numeric] Correspondant to --id in diamond. Default: 95
    -dssc|--db_search_sub_cover      [numeric] Correspondant to --subject-cover in diamond. Default: 60
    -dso|--db_search_outfmt          [numeric] Correspondant to --outfmt in diamond. Default: 6
    -dsb|--db_search_b               [numeric] Correspondant to -b in diamond. Default: 6
    -dsm|--db_search_max_tar_seqs    [numeric] Correspondant to --max-target-seqs in diamond. Default: 1
    -dm|--db_masking                 [numeric] Correspondant to --masking in diamond. Default: 0
