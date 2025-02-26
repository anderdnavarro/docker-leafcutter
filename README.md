Dockerfile used to run [leafcutter](https://github.com/davidaknowles/leafcutter) and [leafviz](https://github.com/jackhump/leafviz).

Adapted from https://github.com/apaul7/docker-leafcutter

# Installation

```bash
# Docker
docker pull anderdnavarro/leafcutter

# Singularity
singularity build leafcutter.sif docker://anderdnavarro/leafcutter
```

# How to use

To run leafcutter with this image you need to enter the container and run the `leafcutter.sh` or `leafcutterMD.sh` commands there.

```bash
# Docker
docker run --rm -u $(id -u):$(id -g) \
           -v $(pwd):/home \
           -v /PATH_TO_GTF/:/genome \ #Only necessary for leafcutter.sh
           -it anderdnavarro/leafcutter

# Singularity 
singularity shell -H $(pwd):/home \
                  -B /PATH_TO_GTF/:/genome \ #Only necessary for leafcutter.sh
                  leafcutter.sif
```