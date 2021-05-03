rule quast:
    input: 
        "results/spades_{sample}"
    output: 
        directory("results/quast_{sample}")
    conda:
        "../envs/assembly.yaml"
    threads: threads
    params:
        **config["params"]
    log: 
        "results/logs/quast/{sample}.log"
    shell:
        "python quast.py {params.quast} --threads {threads} -o {output} {input}/scaffolds.fasta 2> {log}"