# Genome Assembly and Analysis Workflow
This is a Nextflow Workflow for Genome Assembly and Genotyping which processes paired end read sets.

## Overview

This Nextflow workflow is designed to perform genome assembly, quality assessment, and genotyping on paired-end read data. It utilizes the SKESA assembler for genome assembly, QUAST for quality assessment, and MLST for genotyping. The workflow takes paired-end read data in fastq.gz format as input and produces assembled genome sequences, quality assessment reports, and MLST results as output. It performs MLST and QUAST analyses in parallel after assembling the genome from the reads. 'file.htm' contains the directed acyclic graph for the workflow which shows that MLST and QUAST were executed in parallel. Sample inputs and outputs have been provided in the 'testreads' and 'testresults' folders.


## Setup

### Conda Environment

To set up the required dependencies, we can create a Conda environment as shown below:

```bash
conda create -n workflow python
conda install -c bioconda skesa nextflow mlst
conda activate workflow
```    

### Input Files

The workflow expects an input directory path as a parameter which should contain compressed read files as-  

`{SRR_ID}.1.fastq.gz`           
`{SRR_ID}.2.fastq.gz`

### Output Files

The script will produce an assembled genome inn '.fna' format in the 'assembly' folder, MLST results in a TSV format in the 'genotyping' folder and QUAST results within the 'quality_assessment' folder present inside the output directory passed to the script during runtime.


## Execution

The script can be run as follows-
```bash
nextflow run main.nf --readsPath 'path/to/input/file/directory' --resultsPath 'path/to/output/file/directory'
```  
### The Directed Acyclic Graph during a Run of this Workflow has been included below, which shows Process Parallelization.

![Directed Acyclic Graph during a Run of this Workflow](https://github.gatech.edu/storage/user/82489/files/896f8731-7cf1-473e-9795-91e3478ebfed)
