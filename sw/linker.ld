ENTRY(_start)

MEMORY {
  RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 64k
}

SECTIONS {
  .text : {
    *(.text*)
  } > RAM

  .bss : {
    *(.bss*)
    *(COMMON)
  } > RAM
}
