#include "Vtop.h"
#include "verilated.h"
#include <iostream>
int cycle=0;
void print_state(Vtop *top) {
  std::cout<<std::hex<<cycle<<"\t"<<top->pc<<"\t"<<top->inst<<"\n";

}
void step(Vtop *top,VerilatedContext *contextp){
  top->clk=1;
  top->eval();
  contextp->timeInc(1);
  top->clk=0;
  top->eval();
  contextp->timeInc(1);
  cycle++;
  print_state(top);
}
void top_init(Vtop *top) {
top->clk=0;
top->reset=0;
}
int main(int argc, char **argv) {
  VerilatedContext *contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  Vtop *top = new Vtop{contextp};

  //START
  top_init(top);
  top->reset=1;
  step(top,contextp);
  top->reset=0;
  for(int i=0;i<20;i++)step(top,contextp);
  delete top;
  delete contextp;
  return 0;
}

