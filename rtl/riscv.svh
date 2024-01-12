// riscv.svh

`ifndef __RISCV
`define __RISCV

parameter int STATE_AMOUNT = 3;
typedef enum logic [STATE_AMOUNT-1:0] {
  IDLE,
  FETCH,
  EXECUTE
} state_e;


`endif
