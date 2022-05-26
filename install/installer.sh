#!/bin/bash

#export the path repo in a variable accessible also later
#defining repo path
os=$1
curdir=$PWD
repopath=$(dirname $curdir)

#Installing the conda environments
#install the environments needed (snakemake)
echo "## Creating snakemake env to run porinmatcher"
if <conda --version>;
then
	echo "Conda version found: $(conda --version), proceeding.."
else
	echo "ERROR: No conda version found, you need to have conda installed in order to proceed, 
		Please consult the github page (https://github.com/AlfredoMariUnibas/porins) for more information, Exiting.."
	exit 1
fi 
conda create -p "$repopath"/porinmamba -c conda-forge mamba
conda config --set channel_priority strict
source activate "$repopath"/porinmamba
mamba create -c conda-forge -c bioconda -p "$repopath"/porinsnakemake snakemake



#export path to porimatcher script to bashrc and to the current shell
echo "## Loading paths in .porinmatcherrc .."
porinrc=~./porinmatcherrc
if [[ "$os" == "mac"  ]];
then
	rc=~/.zprofile
elif [["$os" == "linux" ]];
then
	rc=~/.bashrc
else
	echo "
		You specified nor linux nor mac installation, Note that this software works only to the above mentioned platfomrs. 
		The profile file not found, please contact a developer by reporting a bug on the github page (https://github.com/AlfredoMariUnibas/porins) or by sending an email to alfroit90@gmail.com 
"
	exit 1
fi

if [ -e ${rc} ];
then
	echo "$rc found, adding script path and repopath.. "
	echo "export PORINMATCHERREPO=$repopath" > $porinrc
	echo "alias porinmatcher='$repopath/porinmatcher'" >> $porinrc
	echo "Paths added, sourcing the path to $rc"
	if ! grep -q porinmatcher "$rc"; 
	then
		echo "source $porinrc" >> $rc
	else
		echo "$rc contains already the sourcing to $porinrc, skipping the step.."
	fi
else
	echo "$rc not found, creating one and adding script path.."
        echo "export PORINMATCHERREPO=$repopath" > $porinrc
        echo "alias porinmatcher='$repopath/porinmatcher'" >> $porinrc
        echo "Paths added, sourcing the path to $rc"
	echo "source $porinrc" > $rc	
fi
echo "Porinmatcher script installed, now proceeding with the environments.."
#activate the changes
source ~/.bashrc
#install the environments needed (snakemake)
echo "## Creating snakemake env to run porinmatcher"
conda create -p "$repopath"/porinmamba -c conda-forge mamba
conda config --set channel_priority strict
source activate "$repopath"/porinmamba
mamba create -c conda-forge -c bioconda -p "$repopath"/porinsnakemake snakemake

echo "## Environments created, software installed, please restart the shell in order to use it.
	To test the installation, type in a new shell 
	porinmathcer --help"
