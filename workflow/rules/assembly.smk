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
        "quast.py {params.quast} --threads {threads} -l spades,skesa -o {output} {input[0]}/scaffolds.fasta {input[1]} 2> {log}"

rule check_best_assembly:
    input: 
        spades="results/spades_{sample}",
        skesa="results/skesa_{sample}/contigs.fasta",
        quast="results/quast_{sample}"
    output: 
        "results/best_assembly_{sample}/final_assembly.fa"
    run:
        import pandas as pd
        from shutil import copy

        quast = pd.read_csv(f"{input.quast}/report.tsv", sep="\t", header=0).set_index("Assembly", drop=False)
        quast.drop('Assembly', axis='columns', inplace=True)

        score = { i : 0 for i in quast.columns.to_list() }
        number_contigs = quast.loc['# contigs'].to_dict()
        largest_contig = quast.loc['Largest contig'].to_dict()
        total_length = quast.loc['Total length'].to_dict()
        n50 = quast.loc['N50'].to_dict()
        n75 = quast.loc['N75'].to_dict()
        predict_genes = quast.loc['# predicted genes (unique)'].to_dict()

        score[min(number_contigs, key=number_contigs.get)] += 1
        score[max(largest_contig, key=largest_contig.get)] += 1
        score[max(total_length, key=total_length.get)] += 1
        score[max(n50, key=n50.get)] += 1
        score[max(n75, key=n75.get)] += 1
        score[max(predict_genes, key=predict_genes.get)] += 3

        assembly = max(score, key=score.get)

        print(score)

        if assembly == 'spades':
            copy(f'{input.spades}/scaffolds.fasta', f'{output[0]}') 
        elif assembly == 'skesa':
            copy(f'{input.skesa}', f'{output[0]}') 

