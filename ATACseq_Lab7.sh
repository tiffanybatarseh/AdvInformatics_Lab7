#!/bin/bash
#$ -N advinf_ATACseq
#$ -q class
#$ -pe openmp 2
#$ -R y
#$ -t 1-24
#$ -m beas

cd /pub/tbatarse/Bioinformatics_Course/ATACseq

module load bwa/0.7.8
module load samtools/1.3
module load bcftools/1.3
module load enthought_python/7.3.2
module load gatk/2.4-7
module load picard-tools/1.87
module load java/1.7

ref="/pub/tbatarse/Bioinformatics_Course/ref/dmel-all-chromosome-r6.13.fasta"

bwa index ${ref}
samtools faidx ${ref}
java -d64 -Xmx128g -jar /data/apps/picard-tools/1.87/CreateSequenceDictionary.jar R=${ref} O=/pub/tbatarse/Bioinformatics_Course/ref/dmel-all-chromosome-r6.13.dict

#rawfix=`head -n $SGE_TASK_ID ATACseq.prefixes.txt | tail -n 1 | cut -f1`
prefix=`head -n $SGE_TASK_ID ATACseq.prefixes.txt | tail -n 1 | cut -f2`

dictfile="/pub/tbatarse/Bioinformatics_Course/ref/dmel-all-chromosome-r6.13.dict"

bwa mem -t 8 -M ${ref} ${prefix}_R1.fq.gz ${prefix}_R2.fq.gz | samtools view -bS - > ${prefix}.bam

samtools sort ${prefix}.bam -o ${prefix}.sort.bam

java -Xmx20g -jar /data/apps/picard-tools/1.87/AddOrReplaceReadGroups.jar I=${prefix}.sort.bam O=${prefix}.RG.bam SORT_ORDER=coordinate RGPL=illumina RGPU=D109LACXX RGLB=Lib1 RGID=${prefix} RGSM=${prefix} VALIDATION_STRINGENCY=LENIENT

samtools index ${prefix}.RG.bam
