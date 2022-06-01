#!/bin/bash

#export the path repo in a variable accessible also later
#defining repo path
os=$1
curdir=$PWD
repopath=$(dirname $curdir)

#Installing the conda environments
#install the environments needed (snakemake)
echo "## Creating snakemake env to run porinmatcher"
conda --version
if [ $? = 0 ];
then
	echo "Conda version found: $(conda --version), proceeding.."
else
	echo "ERROR: No conda version found, you need to have conda installed in order to proceed, 
		Please consult the github page (https://github.com/AlfredoMariUnibas/porins) for more information, Exiting.."
	exit 1
fi 

if [ ! -d "$repopath"/porinmamba ];
then
	echo "Mamba not found, building it.."
	conda create -p "$repopath"/porinmamba -c conda-forge mamba
else
	echo "Mamba already present, moving forward.."
fi
conda config --set channel_priority strict
source activate "$repopath"/porinmamba

if [ ! -d "$repopath"/porinsnakemake ];
then
        echo "Snakemake not found, building it.."
	mamba create -c conda-forge -c bioconda -p "$repopath"/porinsnakemake snakemake
else
        echo "Snakemake already present, moving forward.."
fi



#export path to porimatcher script to bashrc and to the current shell
echo "## Loading paths in .porinmatcherrc .."
porinrc=~/.porinmatcherrc
if [[ "$os" == "mac"  ]];
then
	rc=~/.zprofile
	sed -n s/renv_placeholder/\$piperoot\/snakemake\/config\/dependencies\/R_mac.yaml/g 
elif [[ "$os" == "linux" ]];
then
	rc=~/.bashrc
	sed -n s/renv_placeholder/\$piperoot\/snakemake\/config\/dependencies\/R_linux.yaml/g
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
echo "Porinmatcher script installed.."
#activate the changes
source $rc
echo "## Environments created, software installed successfully. To test the installation, type 
	porinmatcher --help"
