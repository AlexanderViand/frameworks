#!/bin/bash 

# Number of seperate nodes (=machines), including the aggregator (always ID 1)
NODES=11

# base_port, ports will be base_port+ID
PORT=9100

# Total number of logical teachers (=trained models)
TEACHERS=250 
    
TEACHERS_PER_NODE=$(( $TEACHERS / $NODES ))


echo "Setting up $NODES nodes."
mkdir -p deployment
cd deployment
mkdir -p keys # for public keys

echo "Setting up keys"
for (( ID=1; ID<=$NODES; ID++ ))
do
    # Create folder, if necessary
    mkdir -p node$ID
    cd node$ID

    # Setting up keys
    mkdir -p keys
    cd keys
    openssl genrsa -out private$ID.pem &>/dev/null
    openssl rsa -in private$ID.pem -outform PEM -pubout -out pubkey$ID.pem &>/dev/null
    cp pubkey$ID.pem ../../keys/pubkey$ID.pem #copy of the pubkey for everybody
    cd .. #back to node

    cd .. #back to deployment
done

# Copy public keys down
for (( ID=1; ID<=$NODES; ID++ ))
do  
    cp -r keys node$ID        
done


echo "Setting up configs"
for (( ID=1; ID<=$NODES; ID++ ))
do    
    cd node$ID

    # Setting up smc_config
    printf "modulus:48\ncomp-parties:$NODES\nthreshold:$(( ($NODES / 2 ) - 1 ))\ninput-parties:$(($NODES-1))\noutput-parties:1\n" > smc_config

    # Setting up run_config
    for (( I=1; I<=$NODES; I++ ))
    do
        printf "$I,127.0.0.1,$(($PORT+$I)),keys/pubkey$I.pem\n" > run_config
        #TODO: Make them use real ips rather than localhost
    done
  
    # Setting up input, hardcoded to ten classes for now
    echo "v$ID = 1,0,0,0,0,0,0,0,0,0\n" > input
    #TODO: Make vote random, or read it from file    

    cd .. #back to deployment
done

echo "Frankensteinifing the source code for the appropriate number of nodes"
#TODO: ACTUALLY DO THIS!

echo "Transpiling code"
for (( ID=1; ID<=$NODES; ID++ ))
do    
    cp ../pate.c node$ID/pate.c
    cd node$ID
    picco pate.c smc_config pategen util_config     
    cd .. #back to deployment
done

echo "Generating input shares" 
for (( ID=1; ID<=$NODES; ID++ ))
do       
    cd node$ID
    picco-utility -I $ID input util_config input${ID}share
    #TODO: WILL FAIL UNTIL REAL SOURCE CODE MATCHES!!!
    cd .. #back to deployment
done

#TODO: Copy compute, compile 

#TODO: Run in descending order




