#!/bin/bash

#export the path repo in a variable accessible also later
#defining repo path
curdir=$PWD
repopath=$(dirname $curdir)


#export path to porimatcher script to bashrc and to the current shell
echo "## Loading paths in .bashrc .."
bashrc=~/.bashrc
if [ -e ${bashrc} ];
then
	echo "~/.bashrc found, adding script path and repopath.. "
	echo "export PORINMATCHERREPO=$repopath" >> $bashrc
	echo "alias porinmatcher='$repopath/porinmatcher'" >> $bashrc
	echo "Paths added.."
else
	echo "~/.bashrc not found, creating one and adding script path.."
        echo "export PORINMATCHERREPO=$repopath" > $bashrc
        echo "alias porinmatcher='$repopath/porinmatcher'" >> $bashrc
        echo "Paths added.."
fi
#activate the changes
source ~/.bashrc
#install the environments needed (snakemake)
echo "## Creating snakemake env to run porinmatcher"
conda create -p "$repopath"/porinmamba -c conda-forge mamba
conda activate "$repopath"/porinmamba
mamba create -c conda-forge -c bioconda -p "$repopath"/porinsnakemake snakemake

echo "## Environments created, software installed, please restart the shell in order to use it.
	To test the installation, type in a new shell 
	porinmathcer --help"
