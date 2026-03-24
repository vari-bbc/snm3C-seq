# snm3C-seq

This is a workflow for process snm3C-seq data using [Yet Another Pipeline](https://github.com/lhqing/cemba_data) and other associated packages.

## Table of Contents

* [snm3C-seq](#snm3c-seq)
   * [Table of Contents](#table-of-contents)
   * [Usage](#usage)

## Usage

1. Move your sequencing reads to `raw_data/`

2. Modify the config and samplesheet:
  * config/samplesheet/units.tsv
    * **fq1**           - name of read1 fastq
    * **fq2**           - name of read2 fastq
  * config/allcools_regions_and_quantifiers.tsv defines settings for `allcools generate-dataset --regions` and `--quantifiers`. See [allcools documentation](https://lhqing.github.io/ALLCools/command_line/allcools_dataset.html).
    * **region_name**   - name of the region set
    * **regions**       - either an integer setting bin size or an absolute path to a regions file.
    * **quantifiers**   - space-delimited string setting the quantification type, nucelotide context and cutoff. See documentation for --quantifiers parameter.

