

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "ckb-sphincsplus.h"
#include "randombytes.h"

const char* G_SPHINCS_PLUS_INFO_H = "build/sphincs_plus_info.h";

int format_buf(char* str_buf, uint8_t* data, size_t data_len) {
  int ret = 0;
  for (size_t i = 0; i < data_len; i++) {
    int off = 0;
    if (i + 1 < data_len) {
      off = snprintf(str_buf, 8, "0x%02x,", data[i]);
    } else {
      off = snprintf(str_buf, 8, "0x%02x", data[i]);
    }
    str_buf += off;
    ret += off;
  }
  return ret;
}

int main() {
  uint8_t pubkey[SPX_PK_BYTES] = {0};
  uint8_t prikey[SPX_SK_BYTES] = {0};
  if (sphincs_plus_generate_keypair(pubkey, prikey) != 0) {
    printf("generate sphincs+ key failed\n");
    return 2;
  }

  uint8_t message[SPX_MLEN] = {0};
  uint8_t sign[SPX_BYTES + SPX_MLEN] = {0};
  size_t sign_len = sizeof(sign);

  randombytes(message, sizeof(message));
  if (sphincs_plus_sign(message, prikey, sign, &sign_len) != 0) {
    printf("sphincs+ sign failed\n");
    return 3;
  }

  if (sphincs_plus_verify(sign, sizeof(sign), message, pubkey) != 0) {
    printf("sphincs+ verify failed\n");
    return 4;
  }

  // gen .h file
  int file = open(G_SPHINCS_PLUS_INFO_H, O_WRONLY | O_CREAT, S_IRUSR | S_IWUSR);
  if (file <= 0) {
    printf("Can open file\n");
    return 1;
  }

  char buf[1024 * 1024 * 4] = {0};
  int offset = 0;
  char* cur_buf = buf;

  offset = snprintf(cur_buf, sizeof(buf),
                    "#include <stdint.h>\n\nuint8_t G_PUBLIC_KEY[] = {\n");
  cur_buf += offset;

  offset = format_buf(cur_buf, pubkey, sizeof(pubkey));
  cur_buf += offset;

  offset = snprintf(cur_buf, 1024, "\n};\nint8_t G_PRINVATE_KEY[] = {\n");
  cur_buf += offset;

  offset = format_buf(cur_buf, prikey, sizeof(prikey));
  cur_buf += offset;

  offset = snprintf(cur_buf, 1024, "\n};\nuint8_t G_MESSAGE[] = {\n");
  cur_buf += offset;

  offset = format_buf(cur_buf, message, sizeof(message));
  cur_buf += offset;

  write(file, buf, strlen(buf));
  memset(buf, 0, sizeof(buf));
  cur_buf = buf;

  offset = snprintf(cur_buf, sizeof(buf), "\n};\nuint8_t G_SIGN[] = {\n");
  cur_buf += offset;

  offset = format_buf(cur_buf, sign, sizeof(sign));
  cur_buf += offset;

  snprintf(cur_buf, 1024, "\n};");

  write(file, buf, strlen(buf));
  close(file);
  return 0;
}
