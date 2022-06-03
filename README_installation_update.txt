# Download the github repository
git clone https://github.com/AlfredoMariUnibas/porins ./porinmatcher

# optionally, add porinmatcher to your PATH. In Linux:
echo "export PATH=$PATH:/path/to/porinmatcher/" >> ~/.bashrc && source ~/.bashrc

# conda, DIAMOND, R, and snakemake are required to run porinmatcher. If not already available, we recommend installing them in a separate porinmatcher conda environment (alternatively use mamba for installing packages):

conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

conda create -n porinmatcher && conda activate porinmatcher
conda install -c bioconda snakemake diamond=2.0.15 -y
conda install --strict-channel-priority R=3.6 -y # can be skipped if R already in base

# Run:
conda activate porinmatcher
porinmatcher -t 8 -R results -T PA -Q [path_to_repo]/snakemake/test/Pseudomonas_aeruginosa/