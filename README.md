# snm3C-seq

This is a workflow for process snm3C-seq data using [Yet Another Pipeline](https://github.com/lhqing/cemba_data) and other associated packages.

## Table of Contents

* [snm3C-seq](#snm3c-seq)
   * [Table of Contents](#table-of-contents)
   * [Usage](#usage)

## Usage

1. Clone this repo. You can run `git clone https://github.com/vari-bbc/snm3C-seq.git <path/to/new_folder>`. The cloned folder will be your working directory.

2. Move your sequencing reads to `raw_data/`. 

3. Modify the config and samplesheet:
  * config/config.yaml - This file defines the locations of required configuration files.
  * <yap_config> - The path to this file is defined in `config/config.yaml`. This is the config file for [YAP](https://hq-1.gitbook.io/mc/prepare/prepare-mapping-config).
  * config/samplesheet/units.tsv
    * **fq1**           - name of read1 fastq
    * **fq2**           - name of read2 fastq
  * config/allcools_regions_and_quantifiers.tsv defines settings for `allcools generate-dataset --regions` and `--quantifiers`. See [allcools documentation](https://lhqing.github.io/ALLCools/command_line/allcools_dataset.html).
    * **region_name**   - name of the region set
    * **regions**       - either an integer setting bin size or an absolute path to a regions file.
    * **quantifiers**   - space-delimited string setting the quantification type, nucelotide context and cutoff. See documentation for --quantifiers parameter.

4. If your lab has their own nodes on the VAI HPC, add the partition name to line 4 in the SLURM profile (`profile/generic_slurm/config.v9+.yaml`).  For example, you may modifify it to `-p yourlab,long,short \`.

5. Start the workflow by running `sbatch bin/run_snake.slurm`. Monitor the jobs from this workflow by running `squeue -u user.name`.

6. Check the `snake_workflow.e` log file to see if the workflow ran to completion. Run `tail snake_workflow.e`; there should be a line that says 100% completed or something to that effect.

