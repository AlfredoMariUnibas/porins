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
snakemake -s snake0.smk --threadds [the amount of threads you wish to give]
```
