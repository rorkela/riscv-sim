//#define VCD_out

#include "Vtop.h"
#include "Vtop___024root.h"
#include "verilated.h"
#include "verilated_vcd_c.h" // 1. Include the tracing header
#include <iostream>

int cycle = 0;

void print_state(Vtop *top) {
  auto *r = top->rootp;

  uint32_t ifid_pc = (uint32_t)(r->top__DOT__ifid_r);
  uint32_t ifid_inst = (uint32_t)(r->top__DOT__ifid_r >> 32);

  uint32_t idex_pc = r->top__DOT__idex_r[0];
  uint32_t idex_inst = r->top__DOT__idex_r[1];

  uint32_t exmem_pc = r->top__DOT__exmem_r[0];
  uint32_t exmem_inst = r->top__DOT__exmem_r[1];

  uint32_t memwb_pc = r->top__DOT__memwb_r[0];
  uint32_t memwb_inst = r->top__DOT__memwb_r[1];

  std::cout << std::hex << "cycle=" << cycle << " pc=" << top->pc
            << " inst=" << top->inst
            << " ex_branch=" << r->top__DOT__ex_branch_taken
            << " alu_branch=" << r->top__DOT__alu_branch_taken
            << " stall=" << r->top__DOT__stall << "\n";
printf("%08x\t%08x\t%08x\t%08x\n",
       ifid_pc, idex_pc, exmem_pc, memwb_pc);

printf("%08x\t%08x\t%08x\t%08x\n",
       ifid_inst, idex_inst, exmem_inst, memwb_inst);
}

void step(Vtop *top, VerilatedContext *contextp, VerilatedVcdC *tfp) {
  // Falling edge tracking (before rising edge)
  top->clk = 1;
  top->eval();
  contextp->timeInc(1);

#ifdef VCD_out
  if (tfp)
    tfp->dump(contextp->time()); // 2. Dump data to waveform
#endif

#ifdef VCD_out
  print_state(top);
#endif
  top->clk = 0;
  top->eval();
  contextp->timeInc(1);

#ifdef VCD_out
  if (tfp)
    tfp->dump(contextp->time()); // 3. Dump data to waveform
#endif

  cycle++;
}

void top_init(Vtop *top) {
  top->clk = 0;
  top->reset = 0;
}

int main(int argc, char **argv) {
  VerilatedContext *contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);

  // 4. Enable tracing in the context
  contextp->traceEverOn(true);

  Vtop *top = new Vtop{contextp};

  // 5. Initialize the trace object
  VerilatedVcdC *tfp = new VerilatedVcdC;

#ifdef VCD_out
  top->trace(tfp, 99);       // 99 means trace all hierarchies completely
  tfp->open("waveform.vcd"); // The name of your output file
#endif

  // START
  top_init(top);
  top->reset = 1;
  step(top, contextp, tfp); // Pass tfp to step
  top->reset = 0;

  for (int i = 0; i < 2000; i++) {
    step(top, contextp, tfp); // Pass tfp to step
    // if(top->halt) break;
  }
  int result = top->rootp->top__DOT__reg_file_1__DOT__regfile[3];
  std::cout << std::hex << result << "|"
            << (result == 1 ? "PASS" : "------FAIL-----") << "\n";

// 6. Clean up and close the waveform file
#ifdef VCD_out
  tfp->close();
#endif

  delete tfp;
  delete top;
  delete contextp;
  return 0;
}
