rule spades_assembly:
    input:
        "results/quality_analysis/{sample}",
        fq1="results/quality_analysis/{sample}/{sample}_R1_val_1.fq.gz",
        fq2="results/quality_analysis/{sample}/{sample}_R2_val_2.fq.gz"
    output: 
        directory("results/spades_{sample}")
    conda:
        "../envs/assembly.yaml"
    threads: threads
    params:
        **config["params"]
    log: 
        "results/logs/spades_assembly/{sample}.log"
    shell:
        "spades.py {params.spades} --threads {threads} -1 {input.fq1} -2 {input.fq2} -o {output} 2> {log}"

rule skesa_assembly:
    input: 
        "results/quality_analysis/{sample}",
        fq1="results/quality_analysis/{sample}/{sample}_R1_val_1.fq.gz",
        fq2="results/quality_analysis/{sample}/{sample}_R2_val_2.fq.gz"
    output: 
        "results/skesa_{sample}/contigs.fasta"
    conda:
        "../envs/assembly.yaml"
    threads: threads
    params:
        **config["params"]
    log: 
        "results/logs/skesa_assembly/{sample}.log"
    shell:
        "skesa --cores {threads} --reads {input.fq1},{input.fq2} --contigs_out {output} 2> {log}"

rule quast:
    input: 
        "results/spades_{sample}",
        "results/skesa_{sample}/contigs.fasta"
    output: 
        directory("results/quast_{sample}")
    conda:
        "../envs/assembly_quality.yaml"
    threads: threads
    params:
        **config["params"]
    log: 
        "results/logs/quast/{sample}.log"
    shell:
        "quast.py {params.quast} --threads {threads} -o {output} {input[0]}/scaffolds.fasta {input[1]} 2> {log}"

rule check_best_assembly:
    input: 
        "results/quast_{sample}"
    output: 
        directory("results/best_assembly_{sample}")
    log: 
        "results/logs/quast/{sample}.log"
    run:
        print("")