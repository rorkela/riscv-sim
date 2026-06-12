//#define VCD_out

#include "Vtop.h"
#include "Vtop___024root.h"
#include "verilated.h"
#include "verilated_vcd_c.h" 
#include <iostream>

int cycle = 0;

// Performance Tracking Variables
bool count_started = false;
bool count_finished = false;
int start_cycle = 0;
int stop_cycle = 0;

void print_state(Vtop *top) {
  auto *r = top->rootp;

  uint32_t ifid_pc   = (uint32_t)(r->top__DOT__ifid_r);
  uint32_t ifid_inst = (uint32_t)(r->top__DOT__ifid_r >> 32);

  uint32_t idex_pc   = r->top__DOT__idex_r[0];
  uint32_t idex_inst = r->top__DOT__idex_r[1];

  uint32_t exmem_pc  = r->top__DOT__exmem_r[0];
  uint32_t exmem_inst = r->top__DOT__exmem_r[1];

  uint32_t memwb_pc  = r->top__DOT__memwb_r[0];
  uint32_t memwb_inst = r->top__DOT__memwb_r[1];

  std::cout << std::hex << "cycle=" << cycle << " pc=" << top->pc
            << " inst=" << top->inst
            << " ex_branch=" << (int)r->top__DOT__ex_branch_taken
            << " alu_branch=" << (int)r->top__DOT__alu_branch_taken
            << " stall=" << (int)r->top__DOT__stall << "\n";
  
  printf("%08x\t%08x\t%08x\t%08x\n", ifid_pc, idex_pc, exmem_pc, memwb_pc);
  printf("%08x\t%08x\t%08x\t%08x\n\n", ifid_inst, idex_inst, exmem_inst, memwb_inst);
}

void step(Vtop *top, VerilatedContext *contextp, VerilatedVcdC *tfp) {
  auto *r = top->rootp;

  // 1. Clock High (Rising Edge evaluation)
  top->clk = 1;
  top->eval();
  contextp->timeInc(1);

#ifdef VCD_out
  if (tfp) tfp->dump(contextp->time()); 
  print_state(top);
#endif

  // --- DHRYSTONE EXTERNAL TRACKING LOGIC ---
  uint32_t ifid_pc  = (uint32_t)(r->top__DOT__ifid_r);
  uint32_t idex_pc  = r->top__DOT__idex_r[0];
  uint32_t exmem_pc = r->top__DOT__exmem_r[0];
  uint32_t memwb_pc = r->top__DOT__memwb_r[0];

  // Start Condition: PC enters the Fetch stage
  if (!count_started && top->pc == 0x80003164) {
    start_cycle = cycle;
    count_started = true;
    std::cout << "\n[TIMER] Dhrystone loop started at cycle: " << std::dec << start_cycle << std::hex << "\n";
  }

  // Stop Condition: The last iteration target passes out of Writeback
  if (count_started && !count_finished && memwb_pc == 0x800032e8) {
    stop_cycle = cycle;
    count_finished = true;
    std::cout << "[TIMER] Dhrystone loop finished at cycle: " << std::dec << stop_cycle << std::hex << "\n";
  }

  // 2. Clock Low (Falling Edge)
  top->clk = 0;
  top->eval();
  contextp->timeInc(1);

#ifdef VCD_out
  if (tfp) tfp->dump(contextp->time());
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
  contextp->traceEverOn(true);

  Vtop *top = new Vtop{contextp};
  VerilatedVcdC *tfp = new VerilatedVcdC;

#ifdef VCD_out
  top->trace(tfp, 99);       
  tfp->open("waveform.vcd"); 
#endif

  // RESET
  top_init(top);
  top->reset = 1;
  step(top, contextp, tfp); 
  top->reset = 0;

  // RUN MAIN LOOP
  // Expanded to 100000 cycles because software integer emulation routines 
  // take significantly longer than hardware M-extension pipelines.
  for (int i = 0; i < 100000; i++) {
    step(top, contextp, tfp); 

    auto *r = top->rootp;
    uint32_t ifid_pc  = (uint32_t)(r->top__DOT__ifid_r);
    uint32_t idex_pc  = r->top__DOT__idex_r[0];
    uint32_t exmem_pc = r->top__DOT__exmem_r[0];
    uint32_t memwb_pc = r->top__DOT__memwb_r[0];

    // Trapping Exit Condition: Pipeline completely filled with the exit address loop
    if (top->pc == 0x80000010 && ifid_pc == 0x80000010 && 
        idex_pc == 0x80000010 && exmem_pc == 0x80000010 && memwb_pc == 0x80000010) {
      std::cout << "\n[EXIT] Pipeline cleanly settled into _exit trap. Halting simulation.\n";
      break;
    }
  }

  // POST-RUN PERFORMANCE EVALUATION
  std::cout << "\n==================================================\n";
  std::cout << "               DHRYSTONE RESULTS                  \n";
  std::cout << "==================================================\n";
  
  if (count_started && count_finished) {
    int total_loop_cycles = stop_cycle - start_cycle;
    double cycles_per_run = (double)total_loop_cycles / 500.0;
    double dmips_per_mhz  = 1000000.0 / (cycles_per_run * 1757.0);

    std::cout << "Total Loop Clock Cycles: " << std::dec << total_loop_cycles << "\n";
    std::cout << "Clock Cycles per Iteration: " << cycles_per_run << "\n";
    std::cout << "Calculated Score: " << dmips_per_mhz << " DMIPS/MHz\n";
  } else {
    std::cout << "ERROR: Timer did not capture both boundary checkpoints.\n";
    std::cout << "Start captured: " << (count_started ? "YES" : "NO") << "\n";
    std::cout << "Stop captured:  " << (count_finished ? "YES" : "NO") << "\n";
  }
  std::cout << "==================================================\n\n";

  // Check register signature output 
  int result = top->rootp->top__DOT__reg_file_1__DOT__regfile[3];
  std::cout << std::hex << "Reg x3 Signature: " << result << " | "
            << (result == 1 ? "PASS" : "------FAIL-----") << "\n";

#ifdef VCD_out
  tfp->close();
#endif

  delete tfp;
  delete top;
  delete contextp;
  return 0;
}
