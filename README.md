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
Snakemake runs best if contextually mamba is installed as well
```
$ conda install -n base -c conda-forge mamba
$ conda activate base
$ mamba create -c conda-forge -c bioconda -p path/to/your/snakemake snakemake
$ conda activate path/to/your/snakemake
```
Afterwards, to import the scripts and the dependencies, clone this repository to your directory of choice

```
$ git clone https://github.com/AlfredoMariUnibas/porins path/to/PorinMatcher
```

PorinMatcher utilises snakemake and diamond to match each database with each genome, and it is optimised to achieve this with parallel computing. To utilise its power to the max, it is reccommended to allocate a number of threads of 4 or multiple of 4. 

### Running the pipe
Once snakemake is properly installed, running PorinMatcher in its default options is straight forward

```
$ snakemake -s path/to/PorinMatcher/snakemake/snake0.smk --use-conda --cores 4
```
### Parametrisation
A number of parameters are customisable and are mostly concerning the diamond blast. In order to apply a different parameter from the default, just state it in the commandline using the config flag of snakemake:
For example, to source a different directory in which the pipe should source the query genomes type the following:
```
$ snakemake -s path/to/PorinMatcher/snakemake/snake0.smk --use-conda --cores 4 --config q_dir=../my_reads/
```
please note that if no `--config` flag is used, the default parameters will apply. Please find below a list of each customisable parameter, and its defaults

### Parameters
| Parameter | Description | Default |
|:--------|:---------:|------:|
| db_dir | Directory containing the databases [string/path] | databases/ |
| q_dir | Directory containing the query genomes [string/path] | queries/ |
| processed_db_dir | Directory outputting the formatted databases [string/path] | formatted_db/ |
| results_dir | Directory contianing the results [string/path] | results/ | 
| db_search_gencode| Correspondant of `--query-gencode` in diamond [integer] | 11 |
| db_search_p | Correspondant of `-p` in diamond [integer] | 16 |
| db_search_id | Correspondant of `--id` in diamond [integer] | 70 |
| db_search_sub_cover | Correspondant of `--subject-cover` in diamond [integer] | 50 |
| masking | Correspondant of `--masking` in diamond [integer] | 0 |
| db_search_outfmt | Correspondant of `--outfmt` in diamond [integer] | 6 |
| db_search_b | Correspondant of `-b` in diamond [integer] | 6 |
| db_search_max_tar_seqs | Correspondant of `--max-target-seqs` in diamond [integer] | 10 |
