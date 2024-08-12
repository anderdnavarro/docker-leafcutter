# Tutorial -> https://davidaknowles.github.io/leafcutter/articles/Usage.html

# 1. Options
mkdir leafcutter leafcutter/juncs leafcutter/clusters leafcutter/differential_splicing
bamsdir=''
output_prefix=''

# 2. Converting BAMs to JUNCs
## -s = strandness (https://rnabio.org/module-09-appendix/0009/12/01/StrandSettings/)
## -a 8 = anchor length 
## -m and -M = minimum and maximum intron lengths
cd leafcutter/juncs
for sample in $(ls ${bamsdir}); do
    echo Converting ${sample}
    /opt/regtools/regtools junctions extract -s RF -a 8 -m 50 -M 500000 ${bamsdir}/${sample}/${sample}.Aligned.sortedByCoord.out.bam -o ${sample}.junc
    echo ${sample}.junc >> juncfiles.txt
done

# 3. Intron clustering
## -m = minimum number of reads supporting each cluster
## -l = maximum intron length
cd ../clusters
python2.7 /git/leafcutter/clustering/leafcutter_cluster_regtools.py -j ../juncs/juncfiles.txt -m 50 -l 500000 -o ${output_prefix}

# GTF to Exon for Gencode v44 (hg38)
cd ../differential_splicing
Rscript /git/leafcutter/scripts/gtf_to_exons.R /genome/gencode_v44/gencode.v44.basic.annotation.nochr.sorted.gtf.gz gencode_v44_hg38_exons_nochr.txt.gz

# Differential intron excision
Rscript /git/leafcutter/scripts/leafcutter_ds.R --num_threads 4 --output_prefix ${output_prefix} --min_samples_per_intron 4 --exon_file gencode_v44_hg38_exons_nochr.txt.gz ../clusters/${output_prefix}_perind_numers.counts.gz groups_file.txt
