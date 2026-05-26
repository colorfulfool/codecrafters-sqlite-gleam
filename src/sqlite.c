#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <arpa/inet.h>

typedef struct {
  char format[16];
  uint16_t page_size; // hex 10 00 => bin 00010000 00000000
  char empty2[10];
  uint32_t db_size;
} preamble_t;

static preamble_t preamble;

int main(int argc, char** argv) {
  if (argc == 3 && strcmp(argv[2], ".dbinfo") == 0) {
    FILE *file = fopen(argv[1], "r");

    fread(&preamble, 1, sizeof(preamble_t), file);

    preamble.page_size = ntohs(preamble.page_size);
    preamble.db_size = ntohl(preamble.db_size);

    printf("format: %s\n", preamble.format);
    printf("database page size: %hu\n", preamble.page_size);
    printf("number of tables: %u\n", preamble.db_size - 1);
  } else {
    printf("Unknown command\n");
  }
}
