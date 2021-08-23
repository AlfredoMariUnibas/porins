# Porins
Repo for porin loss pipeline development
## Structure
The scicore directory contains the original scripts used on scicore, the snakemake dir the developing of the snakemake pipe
### Running the pipe:
Main requirement is to have:
=> conda v4.9
=> snakemake 6.6

Command:
```
snakemake -s snake0.smk --cores [the amount of threads you wish to give]
```

### Options:
| config | default | note |
|--------|---------|------|
| db_dir | databases/ |
| q_dir | queries/ |
| processed_db_dir | formatted_db/ |
| results_dir| results/ | 
| db_search_gencode| 11 |
| db_search_p | 16 |
| db_search_id | 70 |
| db_search_sub_cover | 50 |
| masking | 0 |
| db_search_outfmt | 6 |
| db_search_b | 6 |
| db_search_max_tar_seqs | 10 |
| out_file | results/Collated_table.txt |
