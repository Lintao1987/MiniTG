#1.TPM and counts
hisat2-build -p 6 TS-RS1.genome.fasta TS-RS1.genome.fasta
gffread TS-RS1.gff -T -o TS-RS1.gtf
bash bam.sh
bash stringtie.sh
bash counts.sh
bash extract_count.sh

#2. eQTL
Rscript eQTL.R

