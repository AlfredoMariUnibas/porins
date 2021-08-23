# PorinMatcher
PorinMatcher performs basic blast search and reporting of intact and partial porin sequences from genome assemblies against an up-to-date and curated database.
## Structure (internal --> to be removed for publishing)
The scicore directory contains the original scripts used on scicore, the snakemake dir the developing of the snakemake pipe
### Installation
Main requirements are have:
- conda v4.9 or higher
- snakemake v6.6 or higher
- git v2.23 or higher

#### Snakemake install:
Snakemake runs the best if contextually mamba is installed as well
```
$ conda install -n base -c conda-forge mamba
$ conda activate base
$ mamba create -c conda-forge -c bioconda -n snakemake snakemake
```
Afterwards, to import the scripts and the dependencies, clone this repository to your directory of choice

```
git clone https://github.com/AlfredoMariUnibas/porins path/to/PorinMatcher
```

PorinMatcher utilises snakemake and diamond to match each database with each genome, and it is optimised to achieve this with parallel computing. To utilise its power to the max, it is reccommended to allocate a number of threads of 4 or multiple of 4. 

### Running the pipe
Once snakemake is properly installed, running PorinMatcher in its default options is straight forward

```
snakemake -s path/to/PorinMatcher/snakemake/snake0.smk --use-conda --cores 4
```
### Parametrisation
A number of parameters are customisable and are mostly concerning the diamond blast. In order to apply a different parameter from the default, just state it in the commandline using the config flag of snakemake:
For example, to source a different directory in which the pipe should source the query genomes type the following:
```
snakemake -s path/to/PorinMatcher/snakemake/snake0.smk --use-conda --cores 4 --config q_dir=../my_reads/
```
please note that if no `--config` flag is used, the default parameter will apply. Please find below a list of each customisable parameter, and its defaults

### Paramters
| Parameter | Description | Default |
|--------|---------|------|
| db_dir | Directory containing the databases | databases/ |
| q_dir | Directory containing the query genomes | queries/ |
| processed_db_dir | Directory outputting the formatted databases | formatted_db/ |
| results_dir | Directory contianing the results | results/ | 
| db_search_gencode| Correspondant of `--query-gencode` of diamond | 11 |
| db_search_p | Correspondant of `-p` of diamond | 16 |
| db_search_id | Correspondant of `--id` of diamond | 70 |
| db_search_sub_cover | Correspondant of `--subject-cover` of diamond | 50 |
| masking | Correspondant of `--masking` of diamond | 0 |
| db_search_outfmt | Correspondant of `--outfmt` of diamond | 6 |
| db_search_b | Correspondant of `-b` of diamond | 6 |
| db_search_max_tar_seqs | Correspondant of `--max-target-seqs` of diamond | 10 |
| out_file | The full path and name of the table collecting all results of the run | results/Collated_table.txt |
