#!/bin/bash
#$ -N advinf_RNAseq
#$ -q class
#$ -pe openmp 8
#$ -R y
#$ -t 1
#$ -m beas

cd /pub/tbatarse/Bioinformatics_Course/RNAseq

#To create the file name text file
#ls *R1_001.fastq.gz | sed 's/_R1_001.fastq.gz//' >RNAseq.prefixes.txt

module load samtools/1.3
module load tophat/2.1.0
module load bowtie2/2.2.7

ref="/pub/tbatarse/Bioinformatics_Course/ref/dmel-all-chromosome-r6.13.fasta"
bowtie2-build ${ref}
prefix=`head -n $SGE_TASK_ID RNAseq.prefixes.txt | tail -n 1 | cut -f2`

multimapping=4
# number of reads reported for multimapping

bowtie2 -k $multimapping -X2000 --mm --threads 8 -x dmel-all-chromosome-r6.13.fasta -1 ${prefix}_R1_001.fastq.gz -2 ${prefix}_R2_001.fastq.gz 2>$log |

samtools view -bS - > ${prefix}.bowtie.bam

samtools sort ${prefix}.bowtie.bam -o ${prefix}.bowtie.sort.bam

samtools index

tophat -p 8 -G /pub/tbatarse/Bioinformatics_Course/ref/dmel-all-r6.13.gtf -o /pub/tbatarse/Bioinformatics_Course/RNAseq dmel-all-chromosome-r6.13.fasta ${prefix}_R1_001.fastq.gz ${prefix}_R2_001.fastq.gz

samtools sort /pub/tbatarse/Bioinformatics_Course/RNAseq/${prefix}_accepted_hits.bam -o /pub/tbatarse/Bioinformatics_Course/RNAseq/${prefix}_accepted_hits.sort.bam

samtools index
