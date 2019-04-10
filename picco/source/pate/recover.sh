#!/bin/bash 

# Number of seperate nodes (=machines), including the aggregator (always highest id) but not the seed node
NODES=4

# do not modify!
INPUT=$((NODES-1))
OUTPUT=1

cd deployment
mkdir -p output

echo "Recovering output"
for (( ID=1; ID<=$NODES; ID++ ))
do
    cp node$ID/output$ID output/output$ID
done
cp node1/util_config output/util_config
cd output
picco-utility -O 11 output util_config result.txt
cat result.txt