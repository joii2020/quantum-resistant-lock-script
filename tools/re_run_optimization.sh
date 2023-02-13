rm build/verify

make c/ref/risc-v-asm/riscv_keccak_f1600_bin.S

make -f tests/sphincsplus/optimization/Makefile
if (( $? == 0 ))
then
    echo "Make Success"
else
    exit 1
fi

ckb-debugger --bin build/verify --max-cycles=100000000
if (( $? == 0 ))
then
    echo "Run Success"
else
    exit 1
fi