
HASH_NAME=$1
HASH_SIZE=$2
THASH=$3
HASH_OPTION=$4
PARAMS="sphincs-$HASH_NAME-$HASH_SIZE$HASH_OPTION"

cd ../
make clean
make -f tests/sphincsplus/optimization/Makefile all
make gen_pporf PARAMS=$PARAMS THASH=$THASH
if (( $? == 0 ))
then
    echo "Make contract succcess"
else
    exit 1
fi

$flame_graph/flamegraph.pl build/out.tmp > flame_graph/$PARAMS-$THASH.svg
