#define aba 0(a0)
#define abe 8(a0)
#define abi 16(a0)
#define abo 24(a0)
#define abu 32(a0)

#define aga 40(a0)
#define age 48(a0)
#define agi 56(a0)
#define ago 64(a0)
#define agu 72(a0)

#define aka 80(a0)
#define ake 88(a0)
#define aki 96(a0)
#define ako 104(a0)
#define aku 112(a0)

#define ama 120(a0)
#define ame 128(a0)
#define ami 136(a0)
#define amo 144(a0)
#define amu 152(a0)

#define asa 160(a0)
#define ase 168(a0)
#define asi 176(a0)
#define aso 184(a0)
#define asu 192(a0)

#define bca 0(a1)
#define bce 8(a1)
#define bci 16(a1)
#define bco 24(a1)
#define bcu 32(a1)

#define da 40(a1)
#define de 48(a1)
#define di 56(a1)
#define do 64(a1)
#define du 72(a1)

#define eba 80(a1)
#define ebe 88(a1)
#define ebi 96(a1)
#define ebo 104(a1)
#define ebu 112(a1)

#define ega 120(a1)
#define ege 128(a1)
#define egi 136(a1)
#define ego 144(a1)
#define egu 152(a1)

#define eka 160(a1)
#define eke 168(a1)
#define eki 176(a1)
#define eko 184(a1)
#define eku 192(a1)

#define ema 200(a1)
#define eme 208(a1)
#define emi 216(a1)
#define emo 224(a1)
#define emu 232(a1)

#define esa 240(a1)
#define ese 248(a1)
#define esi 256(a1)
#define eso 264(a1)
#define esu 272(a1)

.text
.globl riscv_keccak_f1600
.align 4
# a0 state ptr
# a1 stack_buf
# a2 keccakf_roundconstants
# a3 round
riscv_keccak_f1600:
# bca = aba ^ aga ^ aka ^ ama ^ asa;
ld a7,aba
ld t3,aga
ld t4,aka
ld t5,ama
ld t6,asa
xor a7,a7,t3
xor a7,a7,t4
xor a7,a7,t5
xor a7,a7,t6

# bce = abe ^ age ^ ake ^ ame ^ ase;
ld s7,abe
ld t3,age
ld t4,ake
ld t5,ame
ld t6,ase
xor s7,s7,t3
xor s7,s7,t4
xor s7,s7,t5
xor s7,s7,t6

# bci = abi ^ agi ^ aki ^ ami ^ asi;
ld s9,abi
ld t3,agi
ld t4,aki
ld t5,ami
ld t6,asi
xor s9,s9,t3
xor s9,s9,t4
xor s9,s9,t5
xor s9,s9,t6

# bco = abo ^ ago ^ ako ^ amo ^ aso;
ld a5,abo
ld t3,ago
ld t4,ako
ld t5,amo
ld t6,aso
xor a5,a5,t3
xor a5,a5,t4
xor a5,a5,t5
xor a5,a5,t6
sd a5,bco

# bcu = abu ^ agu ^ aku ^ amu ^ asu;
ld a6,abu
ld t3,agu
ld t4,aku
ld t5,amu
ld t6,asu
xor a6,a6,t3
xor a6,a6,t4
xor a6,a6,t5
xor a6,a6,t6
sd a6,bcu

li t3,1
# da = bcu ^ rol(bce,1);
# rol s2,s7,t3
.byte 0x33,0x99,0xcb,0x61
xor s2,s2,a6
sd s2,da

# de = bca ^ rol(bci,1);
# rol s3,s9,t3
.byte 0xb3,0x99,0xcc,0x61
xor s3,s3,a7
sd s3,de

# di = bce ^ rol(bco,1);
# rol s4,a5,t3
.byte 0x33,0x9a,0xc7,0x61
xor s4,s4,s7
sd s4,di

# do = bci ^ rol(bcu,1);
# rol s5,a6,t3
.byte 0xb3,0x1a,0xc8,0x61
xor s5,s5,s9
sd s5,do

# du = bco ^ rol(bca,1);
# rol s6,a7,t3
.byte 0x33,0x9b,0xc8,0x61
xor s6,s6,a5
sd s6,du

# aba ^= da;
ld a7,aba
xor a7,a7,s2
sd a7,aba

# bca = aba;
sd a7,bca

# age ^= de;
ld t3,age
xor t3,t3,s3
sd t3,age

# bce = rol(age,44);
li t4,44
# rol s7,t3,t4
.byte 0xb3,0x1b,0xde,0x61
sd s7,bce

# aki ^= di;
ld t3,aki
xor t3,t3,s4
sd t3,aki

# bci = rol(aki,43);
li t4,43
# rol s9,t3,t4
.byte 0xb3,0x1c,0xde,0x61
sd s9,bci

# amo ^= do;
ld t3,amo
xor t3,t3,s5
sd t3,amo

# bco = rol(amo,21);
li t4,21
# rol t6,t3,t4
.byte 0xb3,0x1f,0xde,0x61
sd t6,bco

# asu ^= du;
ld t3,asu
xor t3,t3,s6
sd t3,asu

# bcu = rol(asu,14);
li t4,14
# rol t3,t3,t4
.byte 0x33,0x1e,0xde,0x61
sd t3,bcu

# eba = bca ^ ((~bce) & bci);
# andn t3,s9,s7
.byte 0x33,0xfe,0x7c,0x41
xor t3,a7,t3
# sd t3,eba

# eba ^= keccakf_roundconstants[round];
slli t4,a3,3
add t4,a2,t4
ld t4,0(t4)
xor t3,t3,t4
sd t3,eba

# ebe = bce ^ ((~bci) & bco);
ld t4,bce
# andn t3,t6,s9
.byte 0x33,0xfe,0x9f,0x41
xor t3,t3,t4
sd t3,ebe

# ebi = bci ^ ((~bco) & bcu);
# ebo = bco ^ ((~bcu) & bca);
# ebu = bcu ^ ((~bca) & bce);

ret

