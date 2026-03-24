
checkpoint dmux:
    """
    Demultiplex cells.
    """
    input:
        fq1=expand("raw_data/{fq}", fq=units['fq1'].values),
        fq2=expand("raw_data/{fq}", fq=units['fq2'].values),
        ini=config['yap_config'],
    output:
        ini="results/dmux/mapping_config.ini",
        snakemake="results/dmux/snakemake/hisat3n",
        stats=expand("results/dmux/stats/{fn}", fn=['UIDTotalCellInputReadPairs.csv','demultiplex.stats.csv','fastq_dataframe.csv']),
    log:
        expand("logs/dmux/log.{suff}", suff=['o','e'])
    benchmark:
        "benchmarks/dmux/bench.txt"
    params:
        output_dir = lambda wildcards, output: os.path.dirname(output.ini),
        fq_pattern = lambda wildcards, input: os.path.dirname(input.fq1[0]) + '/*fastq.gz'
    threads: 32
    resources:
        mem_gb=196,
        log_prefix=lambda wildcards: "_".join(wildcards) if len(wildcards) > 0 else "log"
    conda:
        "../envs/cemba_data_env.yaml"
    shell:
        """
        {{
        rm -r {params.output_dir}
        yap demultiplex --fastq_pattern '{params.fq_pattern}' --output_dir {params.output_dir} --config_path {input.ini} --cpu {threads} --aligner hisat3n
        }} 1> {log[0]} 2> {log[1]}
        """


checkpoint mapping:
    """
    Map reads.
    """
    input:
        dmux_subdir="results/dmux/{dirname}"
    output:
        snakefile_mod="results/dmux/{dirname}/Snakefile_mod",
        mapping_summary="results/dmux/{dirname}/MappingSummary.csv.gz",
        allc=directory("results/dmux/{dirname}/allc"),
        allcCGN=directory("results/dmux/{dirname}/allc-CGN"),
        bam=directory("results/dmux/{dirname}/bam"),
        detail_stats=directory("results/dmux/{dirname}/detail_stats"),
        hic=directory("results/dmux/{dirname}/hic"),
    log:
        expand("logs/mapping/{{dirname}}.{suff}", suff=['o','e'])
    benchmark:
        "benchmarks/mapping/{dirname}.txt"
    params:
        orig_snakefile="results/dmux/{dirname}/Snakefile",
        snakefile_mod_basename=lambda wildcards, output: os.path.basename(output.snakefile_mod),
        output_dir = lambda wildcards, output: os.path.dirname(output.mapping_summary),
    threads: 16
    resources:
        mem_gb=230,
        log_prefix=lambda wildcards: "_".join(wildcards) if len(wildcards) > 0 else "log"
    conda:
        "../envs/cemba_data_env.yaml"
    shell:
        """
        {{
        # Add config file
        perl -lne 'print $_; print qq|\\nlocal_config = read_mapping_config()\\nDEFAULT_CONFIG.update(local_config)| if /^REQUIRED_CONFIG/' {params.orig_snakefile} > {output.snakefile_mod}

        # change dir
        cd {params.output_dir}
        
        # run snakefile created by yap demultiplex
        snakemake --cores {threads} --snakefile {params.snakefile_mod_basename}

        }} 1> {log[0]} 2> {log[1]}
        """



def get_allc_files(wildcards):
    dmux_dir = "results/dmux"
    dmux_groups = glob_wildcards(os.path.join(dmux_dir, "{i}/Snakefile")).i

    allc_dirs = [checkpoints.mapping.get(dirname=dirname).output['allc'] for dirname in dmux_groups]
    
    out_allc = list()
    for allc_dir in allc_dirs:
        prefix_cell_ids = glob_wildcards(os.path.join(allc_dir, "{i}.allc.tsv.gz")).i
        curr_allc = expand("{allc_dir}/{prefix_cell_id}.allc.tsv.gz", allc_dir=allc_dir, prefix_cell_id=prefix_cell_ids)
        out_allc = out_allc + curr_allc

    return out_allc



def get_mapping_summaries(wildcards):
    dmux_dir = os.path.dirname(checkpoints.dmux.get().output['ini'])
    dmux_groups = glob_wildcards(os.path.join(dmux_dir, "{i}/Snakefile")).i
    mapping_summaries = expand("results/dmux/{dirname}/MappingSummary.csv.gz", dirname = dmux_groups)
    return mapping_summaries


rule generate_mcds:
    """
    Generate MCDS files from allcool tsv files.
    """
    input:
        mapping_summaries=get_mapping_summaries, # need this to ensure that mapping rule is run first
        allc_files=get_allc_files,
        chrom_sizes=config['chrom_sizes'],
        regions_promoter=config['regions_promoter'],
        regions_gene=config['regions_gene'],
    output:
        allc_table="results/generate_mcds/allc.table",
        allc_mcds="results/generate_mcds/allc.mcds"
    log:
        expand("logs/generate_mcds/log.{suff}", suff=['o','e'])
    benchmark:
        "benchmarks/generate_mcds/bench.txt"
    params:
        allc_files_comma_sep=lambda wildcards, input: ','.join(input.allc_files),
        outdir=lambda wildcards, output: os.path.dirname(output.allc_table),
    threads: 64
    resources:
        mem_gb=480,
        log_prefix=lambda wildcards: "_".join(wildcards) if len(wildcards) > 0 else "log"
    conda:
        "../envs/cemba_data_env.yaml"
    shell:
        """
        {{
        # make allc table
        echo '{params.allc_files_comma_sep}' | perl -lnpe 's:,:\\n:g' | perl -lne '$col2=$_; m|([^/]+).allc.tsv.gz|; print qq|$1\\t$col2|' > {output.allc_table}

        # run generat-dataset
        allcools generate-dataset  \
        --allc_table {output.allc_table} \
        --output_path {params.outdir} \
        --chrom_size_path  {input.chrom_sizes} \
        --obs_dim cell \
        --cpu {threads} \
        --chunk_size 50 \
        --regions chrom100k 100000 \
        --regions chrom5k 5000 \
        --regions promoter {input.regions_promoter} \
        --regions gene {input.regions_gene} \
        --quantifiers chrom100k count CGN,CHN \
        --quantifiers chrom5k hypo-score CGN cutoff=0.9
        }} 1> {log[0]} 2> {log[1]}
        """

