#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <arpa/inet.h>

typedef struct {
  char magic_string[16];
  uint16_t page_size;
  char unused[82];
} file_header_t;

typedef struct __attribute__((packed)) {
  char unused[3];
  uint16_t page_cells;
  char unused2[7];
} page_header_t;

static file_header_t file_header;
static page_header_t page_header;

int main(int argc, char** argv) {
  if (argc == 3 && strcmp(argv[2], ".dbinfo") == 0) {
    FILE *file = fopen(argv[1], "r");

    fread(&file_header, 1, sizeof(file_header), file);
    fread(&page_header, 1, sizeof(page_header), file);
    fclose(file);

    file_header.page_size = ntohs(file_header.page_size);
    page_header.page_cells = ntohs(page_header.page_cells);

    printf("magic string: %s\n", file_header.magic_string);
    printf("database page size: %hu\n", file_header.page_size);
    printf("number of tables: %u\n", page_header.page_cells);
  } else {
    printf("Unknown command\n");
  }
}
