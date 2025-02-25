# Tutorial -> https://davidaknowles.github.io/leafcutter/articles/UsageLeafcutterMD.html

# Instructions
## Docker
docker run --rm -u $(id -u):$(id -g) -v $(pwd):/home -it anderdnavarro/leafcutter
## Singularity 
singularity shell -H $(pwd):/home leafcutter.sif

# 1. Options
bamsdir='/home/'
output_prefix=''
mkdir leafcutterMD leafcutterMD/juncs leafcutterMD/clusters leafcutterMD/excision_splicing_analysis

# 2. Converting BAMs to JUNCs
## -s = strandness (https://rnabio.org/module-09-appendix/0009/12/01/StrandSettings/)
## -a 8 = anchor length 
## -m and -M = minimum and maximum intron lengths
cd leafcutterMD/juncs
for sample in $(ls ${bamsdir} | grep '.bam$'); do
    echo Converting ${sample} to ${sample%.bam}.junc
    /opt/regtools/regtools junctions extract -s RF -a 8 -m 50 -M 500000 ${bamsdir}/${sample} -o ${sample%.bam}.junc
    echo ../juncs/${sample%.bam}.junc >> juncfiles.txt
done

# 3. Intron clustering
## -m = minimum number of reads supporting each cluster
## -l = maximum intron length
cd ../clusters
python2.7 /git/leafcutter/clustering/leafcutter_cluster_regtools.py -j ../juncs/juncfiles.txt -m 50 -l 500000 -o ${output_prefix}

# 4. Outlier intron excision analysis
cd ../excision_splicing_analysis
Rscript /git/leafcutter/scripts/leafcutterMD.R --num_threads 3 -o ${output_prefix} ../clusters/${output_prefix}_perind_numers.counts.gz
