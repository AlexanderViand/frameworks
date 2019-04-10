#!/bin/bash 

# Number of seperate nodes (=machines), including the aggregator (always highest id) but not the seed node
NODES=4

# do not modify!
INPUT=$((NODES-1))
OUTPUT=1

# base_port, ports will be base_port+ID
PORT=9200

# Total number of logical teachers (=trained models)
TEACHERS=250 
    
TEACHERS_PER_NODE=$(( $TEACHERS / $NODES ))

echo "Deleting old deployment"
pkill -f pategen
rm -rf deployment   

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
    cp -rp keys node$ID        
done


echo "Setting up configs"
for (( ID=1; ID<=$NODES; ID++ ))
do    
    cd node$ID

    # Setting up smc_config
    printf "modulus:48\ncomp-parties:$NODES\nthreshold:$(( ($NODES / 2 ) - 1 ))\ninput-parties:$INPUT\noutput-parties:$OUTPUT\n" > smc_config

    # Setting up run_config
    for (( I=1; I<=$NODES; I++ ))
    do
        printf "$I,127.0.0.1,$(($PORT+$I)),keys/pubkey$I.pem\n" >> run_config
        #TODO: Make them use real ips rather than localhost
    done
    cd .. #back to deployment
done

for (( ID=1; ID<=$INPUT; ID++ ))
do    
    cd node$ID
    # Setting up input, hardcoded to ten classes
    echo "v$ID = 1,0,0,0,0,0,0,0,0,0\n" > input
    #TODO: Make vote random, or read it from file    
    cd .. #back to deployment
done


echo "Frankensteinifing the source code for the appropriate number of nodes"
printf "public int main() {\n" > pate.c
printf "    private int<4> v1[10]" >> pate.c
for (( ID=2; ID<=$NODES; ID++ ))
do    
    printf ", v$(($ID))[10]" >> pate.c
done
printf ";\n" >> pate.c
for (( ID=1; ID<=$NODES; ID++ ))
do    
    printf "    smcinput(v$(($ID)),$(($ID)),10);\n" >> pate.c
done
printf "    private int<4> s1[10];\n" >> pate.c
printf "    s1 = v1 + v2;\n" >> pate.c
for (( ID=3; ID<=$NODES;  $ID++ ))
do    
    printf "    s1 = v$(($ID)) + v$(($ID+1));\n" >> pate.c
    $(($ID++))
done
printf "    smcoutput(s1,1,10);\n    return 0;\n" >> pate.c


#TODO in next part, actually use THIS pate rather than the hadnwritten one!


echo "Transpiling code"
for (( ID=1; ID<=$NODES; ID++ ))
do    
    cp ../pate.c node$ID/pate.c
    cd node$ID
    picco pate.c smc_config pategen util_config     
    cd .. #back to deployment
done

echo "Generating input shares" 
for (( ID=1; ID<=$INPUT; ID++ ))
do       
    cd node$ID

    # Setting up input, hardcoded to ten classes for now
    echo "v$ID = 1,0,0,0,0,0,0,0,0,0\n" > input 

    # Generate input shares
    picco-utility -I $ID input util_config input${ID}share
    for (( I=1; I<=$NODES; I++ ))
    do
        mv input${ID}share$I ../node$I/input${ID}share$I
    done



    cd .. #back to deployment
done

#TODO: Copy code, but compile on different machine?
echo "Compiling code"
cp -r ../picco picco
cp node1/pategen.cpp picco/pategen.cpp
cd picco
make pategen
cd .. # back to deployment

for (( ID=1; ID<=$NODES; ID++ ))
do    
    cp picco/pategen node$ID/pategen   
done

echo "Starting computational nodes"
for (( ID=$NODES; ID >= 1; ID-- ))
do       
    cd node$ID
    STRING="./pategen $(($ID)) run_config keys/private$(($ID)).pem $(($INPUT)) $(($OUTPUT))"
    for (( I=1; I<=$(($INPUT)); I++ ))
    do
    STRING+=" input$(($I))share$(($ID))"
    done

    STRING+=" output &"
    eval $STRING

    sleep 1

    cd .. #back to deployment
done

echo "Start seed"
mkdir -p seed_node
cp -rp keys seed_node
cp node1/run_config seed_node/run_config
cp node1/util_config seed_node/util_config
cd seed_node
picco-seed run_config util_config
cd .. #back to deployment

echo "Recovering output"
#TODO


read -p "Press any key to clean up..."

echo "Killing any leftover processes"
pkill -f pategen

echo "Done"