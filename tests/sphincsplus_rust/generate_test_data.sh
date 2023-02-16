
HASH_NAME=$1
HASH_SIZE=$2
THASH=$3
HASH_OPTION=$4

cargo clean
cargo run --example gen_test_data --no-default-features --features "$HASH_NAME hash_$HASH_SIZE hash_options_$HASH_OPTION thashes_$THASH"
if (( $? == 0 ))
then
    echo "Generate test succcess"
else
    exit 1
fi
cd ../../
