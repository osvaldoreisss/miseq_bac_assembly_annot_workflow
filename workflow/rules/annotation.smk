rule quast:
    input: 
        "results/best_assembly_{sample}/final_assembly.fa"
    output: 
        directory("results/prokka_{sample}")
    conda:
        "../envs/annotation.yaml"
    threads: threads
    log: 
        "results/logs/prokka/{sample}.log"
    shell:
        "prokka --outdir {output} --prefix wildcards.sample {input}/scaffolds.fasta 2> {log}"