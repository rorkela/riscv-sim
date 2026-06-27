#define VCD_out

#include "Vtop.h"
#include "Vtop___024root.h"
#include "verilated.h"
#include "verilated_vcd_c.h" // 1. Include the tracing header
#include <format>
#include <iostream>

int cycle = 0;


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
  //print_state(top);
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
void test(Vtop *top, VerilatedContext *contextp, VerilatedVcdC *tfp, uint32_t a, uint32_t b, int operation){

  top->a=a;
  top->b=b;
  top->mult_trig=1;
  top->op=operation;
  step(top, contextp, tfp);
  top->mult_trig=0;
  for (int i=0;i<100;i++){ 
    if(top->busy)
    step(top,contextp,tfp);
    else break;
  }
    step(top,contextp,tfp);

  uint64_t expected;
  if(operation==1) expected=(int64_t)a*(int64_t)b;
  else expected=(u_int64_t)a*(u_int64_t)b;
  std::cout<<std::format("{}({})\t{}({})\t{}({})\t{}({})\n",top->a, (int32_t)(top->a),top->b, (int32_t)(top->b),top->out, (int64_t)(top->out),expected, (int64_t)(expected)); 


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
  step(top, contextp, tfp);
  // TESTS
  test(top,contextp,tfp,-5,10,1);
  test(top,contextp,tfp,5,10,1);
  test(top,contextp,tfp,5,10,2);
  test(top,contextp,tfp,-5,-10,1);
  test(top,contextp,tfp,5,-10,1);
  test(top,contextp,tfp,-5,10,1);
#ifdef VCD_out
  tfp->close();
#endif

  delete tfp;
  delete top;
  delete contextp;
  return 0;
}
