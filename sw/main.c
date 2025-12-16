#include <stdbool.h>

#define MMIO_PRINT ((volatile int *)0x104)
#define MMIO_DONE ((volatile int *)0x100)

int main() {
  *MMIO_PRINT = 42;
  *MMIO_PRINT = 1337;
  *MMIO_PRINT = 0xdeadbeef;

  *MMIO_DONE = 1;

  while (true) {
  }
}
