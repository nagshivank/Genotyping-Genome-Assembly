#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Setting up command line parameters
params.readsPath = params.readsPath ?: error("Error: Use --readsPath to specify the paired end read set directory.")
params.resultsPath = params.resultsPath ?: error("Error: Use --resultsPath to specify the output result directory")

// Defining the SKESA assembler process
process GenomeAssembler {
    // Tagging each process execution and creating a directory to store the assembly
    tag "${ID}"
    publishDir "${params.resultsPath}/assembly", mode: 'copy'
    
    input:
    tuple val(ID), path(reads)
    
    output:
    tuple val(ID), path("assembly_${ID}.fna")
    
    // Running SKESA on the reads
    script:
    """
    skesa --fastq ${reads[0]},${reads[1]} --cores ${task.cpus} --contigs_out assembly_${ID}.fna
    """
}

// Defining the QUAST process
process QualityAssessment {
    // Tagging each process execution and creating a directory to store the assembly
    tag "${ID}"
    publishDir "${params.resultsPath}/quality_assessment", mode: 'copy'
    
    input:
    tuple val(ID), path(assembly)
    
    output:
    path("quast_output_${ID}")
    
    // Running QUAST on the assembled genome
    script:
    """
    quast.py -o quast_output_${ID} ${assembly}
    """
}

// Defining the MLST process
process Genotyping {
    // Tagging each process execution and creating a directory to store the assembly
    tag "${ID}"
    publishDir "${params.resultsPath}/genotyping", mode: 'copy'
    
    input:
    tuple val(ID), path(assembly)
    
    // Creating a TSV file with MLST results
    output:
    path("mlst_${ID}.tsv")
    
    // Running MLST on the assembled genome
    script:
    """
    mlst ${assembly} > mlst_${ID}.tsv
    """
}

// Defining the overall workflow
workflow {
    // Creating a channel for the reads
    read_channel = Channel.fromFilePairs("${params.readsPath}/*.{1,2}.fastq.gz")

    // Transforming the assembler output using map to send to the next channel
    input_reads = read_channel.map { id, files -> tuple(id, files.collect{ file(it) }) }

    // Executing the assembler process
    assembly = GenomeAssembler(input_reads)
    // Executing the QUAST and MLST processes in parallel on the same assembler output
    quality_assessment = QualityAssessment(assembly.collect())
    genotyping = Genotyping(assembly.collect())
}