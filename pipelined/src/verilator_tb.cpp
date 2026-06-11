#include "Vtop.h"
#include "Vtop___024root.h"
#include "verilated.h"
#include "verilated_vcd_c.h" // 1. Include the tracing header
#include <iostream>

int cycle = 0;

void print_state(Vtop *top) {
  std::cout << std::hex << cycle << "\t" << top->pc << "\t" << top->inst << "\n";
    //sample address wire inside data module if its equal to 32'h80001000, print the value of it.
  std::cout << std::hex << top->rootp->top__DOT__reg_file_1__DOT__regfile[3]<< "\n";
}

void step(Vtop *top, VerilatedContext *contextp, VerilatedVcdC *tfp) {
  // Falling edge tracking (before rising edge)
  top->clk = 1;
  top->eval();
  contextp->timeInc(1);
  if (tfp) tfp->dump(contextp->time()); // 2. Dump data to waveform

  //print_state(top);
  top->clk = 0;
  top->eval();
  contextp->timeInc(1);
  if (tfp) tfp->dump(contextp->time()); // 3. Dump data to waveform

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
  top->trace(tfp, 99); // 99 means trace all hierarchies completely
  tfp->open("waveform.vcd"); // The name of your output file

  // START
  top_init(top);
  top->reset = 1;
  step(top, contextp, tfp); // Pass tfp to step
  top->reset = 0;
  
  for (int i = 0; i < 5000; i++) {
    step(top, contextp, tfp); // Pass tfp to step
    //if(top->halt) break;
  }
  int result=top->rootp->top__DOT__reg_file_1__DOT__regfile[3];
  std::cout << std::hex << result<<"|"<<(result==1?"PASS":"------FAIL-----") <<"\n";

  // 6. Clean up and close the waveform file
  tfp->close();
  delete tfp;
  delete top;
  delete contextp;
  return 0;
}
