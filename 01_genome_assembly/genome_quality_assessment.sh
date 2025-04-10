#1. BUSCO
for i in TS-RS1 TS-RS2
do
#genome
busco -m genome -i ${i}.genome.fasta -o ${i}_genome.busco -l embryophyta_odb10 -c 5
#gene
busco -m tran -i ${i}.new.cds -o ${i}_gene.busco -l embryophyta_odb10 -c 5
done

#2. LAI
for i in TS-RS1 TS-RS2
do
BuildDatabase -name ${i} ${i}.genome.fasta -engine ncbi
RepeatModeler -database ${i} -pa 10 -LTRStruct -engine ncbi >& run.out
RepeatMasker -lib ${i}-families.fa -pa 10 -dir ${i}_mask ${i}.genome.fasta
gt suffixerator -db ${i}.genome.fasta -indexname ${i}.genome.fasta -tis -suf -lcp -des -ssp -sds -dna
gt ltrharvest -index ${i}.genome.fasta -similar 90 -vic 10 -seed 20 -seqids yes -minlenltr 100 -maxlenltr 7000 -mintsd 4 -maxtsd 6 -motif TGCA -motifmis 1 > ${i}.harvest.scn
ltr_finder -D 15000 -d 1000 -L 7000 -l 100 -p 20 -C -M 0.9 ${i}.genome.fasta > ${i}.genome.fasta.finder.scn
LTR_retriever -genome ${i}.genome.fasta -inharvest ${i}.harvest.scn -infinder ${i}.genome.fasta.finder.scn -threads 5
head -2 ${i}.genome.fasta.out.LAI > ${i}.LAI
done

