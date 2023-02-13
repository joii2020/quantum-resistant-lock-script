#undef CKB_DECLARATION_ONLY
#include "entry.h"
#define CKB_DECLARATION_ONLY

#include <ckb_syscalls.h>
#include <stdio.h>

#include "sphincs_plus_info.h"
#include "ckb-sphincsplus.h"
#include "ckb_vm_dbg.h"

int main() {
  // for (int i = 0; i < 1000; i++) {
  if (sphincs_plus_verify(G_SIGN, sizeof(G_SIGN), NULL, G_PUBLIC_KEY)) {
    // printf("verify failed\n");
    return 2;
  }
  // }

  // printf("verify done\n");
  return 0;
}
