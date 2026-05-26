#include <stdio.h>
#include <string.h>
#include <stdint.h>

typedef struct {
  char format[16];
  uint16_t page_size; // 0x1000 => 
  char empty2[10];
  uint32_t db_size;
} preamble_t;

static preamble_t preamble;

int main(int argc, char** argv) {
  if (argc == 3 && strcmp(argv[2], ".dbinfo") == 0) {
    FILE *file = fopen(argv[1], "r");

    // let assert Ok(_bytes) = read_stream.read_bytes_exact(rs, 16)
    // let assert Ok(page_size) = read_stream.read_int16_be(rs)
    // let assert Ok(_bytes) = read_stream.read_bytes_exact(rs, 10)
    // let assert Ok(db_size) = read_stream.read_int32_be(rs)
    fread(&preamble, sizeof(preamble_t), 1, file);

    printf("format: %s\n", preamble.format);
    printf("database page size: %hu\n", preamble.page_size);
    printf("number of tables: %u\n", preamble.db_size - 1);
  } else {
    printf("Unknown command\n");
  }
}
