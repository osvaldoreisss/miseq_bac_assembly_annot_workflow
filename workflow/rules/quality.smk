rule trim_galore:
    input: 
        get_fastq
    output: 
        out_dir = directory("results/quality_analysis/{sample}"),
        ofq1 = "results/quality_analysis/{sample}/{sample}_R1_val_1.fq.gz",
        ofq2 = "results/quality_analysis/{sample}/{sample}_R2_val_2.fq.gz"
    conda:
        "../envs/quality.yaml"
    threads: threads
    params:
        **config["params"]
    log: 
        "results/logs/trim_galore/{sample}.log"
    shell:
        "trim_galore {params.trim} --basename {wildcards.sample} --cores {threads} --output_dir {output.out_dir} {input} 2> {log}"