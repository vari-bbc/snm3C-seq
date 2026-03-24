# snm3C-seq

This is a workflow for process snm3C-seq data using [Yet Another Pipeline](https://github.com/lhqing/cemba_data) and other associated packages.

## Table of Contents



## Usage



### Step 1: Configure the workflow
* Move your sequencing reads to `raw_data/`

* Modify the config and samplesheet:
  * config/samplesheet/units.tsv
    * **sample**        - ID of biological sample; Must be unique.
    * **fq1**           - name of read1 fastq
    * **fq2**           - name of read2 fastq

