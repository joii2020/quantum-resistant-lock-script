#define Aba 0(a0)
#define Abe 8(a0)
#define Abi 16(a0)
#define Abo 24(a0)
#define Abu 32(a0)

#define Aga 40(a0)
#define Age 48(a0)
#define Agi 56(a0)
#define Ago 64(a0)
#define Agu 72(a0)

#define Aka 80(a0)
#define Ake 88(a0)
#define Aki 96(a0)
#define Ako 104(a0)
#define Aku 112(a0)

#define Ama 120(a0)
#define Ame 128(a0)
#define Ami 136(a0)
#define Amo 144(a0)
#define Amu 152(a0)

#define Asa 160(a0)
#define Ase 168(a0)
#define Asi 176(a0)
#define Aso 184(a0)
#define Asu 192(a0)

#define BCa 0(a1)
#define BCe 8(a1)
#define BCi 16(a1)
#define BCo 24(a1)
#define BCu 32(a1)

#define Da 40(a1)
#define De 48(a1)
#define Di 56(a1)
#define Do 64(a1)
#define Du 72(a1)

#define Eba 80(a1)
#define Ebe 88(a1)
#define Ebi 96(a1)
#define Ebo 104(a1)
#define Ebu 112(a1)

#define Ega 120(a1)
#define Ege 128(a1)
#define Egi 136(a1)
#define Ego 144(a1)
#define Egu 152(a1)

#define Eka 160(a1)
#define Eke 168(a1)
#define Eki 176(a1)
#define Eko 184(a1)
#define Eku 192(a1)

#define Ema 200(a1)
#define Eme 208(a1)
#define Emi 216(a1)
#define Emo 224(a1)
#define Emu 232(a1)

#define Esa 240(a1)
#define Ese 248(a1)
#define Esi 256(a1)
#define Eso 264(a1)
#define Esu 272(a1)

.text
.globl riscv_keccak_f1600
.align 4
# a0 state ptr
# a1 stack_buf
# a2 KeccakF_RoundConstants
# a3 round
riscv_keccak_f1600:
  # BCa = Aba ^ Aga ^ Aka ^ Ama ^ Asa;
  ld a7, Aba
  ld t3, Aga
  ld t4, Aka
  ld t5, Ama
  ld t6, Asa
  xor a7, a7, t3
  xor a7, a7, t4
  xor a7, a7, t5
  xor a7, a7, t6

  # BCe = Abe ^ Age ^ Ake ^ Ame ^ Ase;
  ld s7, Abe
  ld t3, Age
  ld t4, Ake
  ld t5, Ame
  ld t6, Ase
  xor s7, s7, t3
  xor s7, s7, t4
  xor s7, s7, t5
  xor s7, s7, t6

  # BCi = Abi ^ Agi ^ Aki ^ Ami ^ Asi;
  ld s9, Abi
  ld t3, Agi
  ld t4, Aki
  ld t5, Ami
  ld t6, Asi
  xor s9, s9, t3
  xor s9, s9, t4
  xor s9, s9, t5
  xor s9, s9, t6

  # BCo = Abo ^ Ago ^ Ako ^ Amo ^ Aso;
  ld a5, Abo
  ld t3, Ago
  ld t4, Ako
  ld t5, Amo
  ld t6, Aso
  xor a5, a5, t3
  xor a5, a5, t4
  xor a5, a5, t5
  xor a5, a5, t6
  sd a5, BCo

  # BCu = Abu ^ Agu ^ Aku ^ Amu ^ Asu;
  ld a6, Abu
  ld t3, Agu
  ld t4, Aku
  ld t5, Amu
  ld t6, Asu
  xor a6, a6, t3
  xor a6, a6, t4
  xor a6, a6, t5
  xor a6, a6, t6
  sd a6, BCu
  
  li t3, 1
  # Da = BCu ^ ROL(BCe, 1);
  rol s2, s7, t3
  xor s2, s2, a6
  sd s2, Da

  # De = BCa ^ ROL(BCi, 1);
  rol s3, s9, t3
  xor s3, s3, a7
  sd s3, De

  # Di = BCe ^ ROL(BCo, 1);
  rol s4, a5, t3
  xor s4, s4, s7
  sd s4, Di

  # Do = BCi ^ ROL(BCu, 1);
  rol s5, a6, t3
  xor s5, s5, s9
  sd s5, Do

  # Du = BCo ^ ROL(BCa, 1);
  rol s6, a7, t3
  xor s6, s6, a5
  sd s6, Du

  # Aba ^= Da;
  ld a7, Aba
  xor a7, a7, s2
  sd a7, Aba

  # BCa = Aba;
  sd a7, BCa

  # Age ^= De;
  ld t3, Age
  xor t3, t3, s3
  sd t3, Age

  # BCe = ROL(Age, 44);
  li t4, 44
  rol s7, t3, t4
  sd s7, BCe

  # Aki ^= Di;
  ld t3, Aki
  xor t3, t3, s4
  sd t3, Aki

  # BCi = ROL(Aki, 43);
  li t4, 43
  rol s9, t3, t4
  sd s9, BCi

  # Amo ^= Do;
  ld t3, Amo
  xor t3, t3, s5
  sd t3, Amo

  # BCo = ROL(Amo, 21);
  li t4, 21
  rol t6, t3, t4
  sd t6, BCo

  # Asu ^= Du;
  ld t3, Asu
  xor t3, t3, s6
  sd t3, Asu

  # BCu = ROL(Asu, 14);
  li t4, 14
  rol t3, t3, t4
  sd t3, BCu

  # Eba = BCa ^ ((~BCe) & BCi);
  andn t3, s9, s7
  xor t3, a7, t3
  # sd t3, Eba

  # Eba ^= KeccakF_RoundConstants[round];
  slli t4, a3, 3
  add t4, a2, t4
  ld t4, 0(t4)
  xor t3, t3, t4
  sd t3, Eba

  # Ebe = BCe ^ ((~BCi) & BCo);
  ld t4, BCe
  andn t3, t6, s9
  xor t3, t3, t4
  sd t3, Ebe

  # Ebi = BCi ^ ((~BCo) & BCu);
  # Ebo = BCo ^ ((~BCu) & BCa);
  # Ebu = BCu ^ ((~BCa) & BCe);

  ret
