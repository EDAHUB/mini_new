#include <stdio.h>
#include "verilated.h"
#include "Vdut_top.h"
#if VM_TRACE
    #include <verilated_vcd_c.h>
#endif

vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time; 
}

int main(int argc, char** argv, char** env) {
    Verilated::debug(0);
    Verilated::randReset(2);
    Verilated::commandArgs(argc, argv);
    Vdut_top * dut = new Vdut_top;  
    
    #if VM_TRACE
        VerilatedVcdC* tfp = NULL;
        const char* flag = Verilated::commandArgsPlusMatch("trace");
        if (flag && 0==strcmp(flag, "+trace")) {
            Verilated::traceEverOn(true);  
            VL_PRINTF("Enabling waves into vrlt_dump.vcd...");
            tfp = new VerilatedVcdC;
            dut->trace(tfp, 99); 
            tfp->open("vrlt_dump.vcd");
        }
    #endif
    
    dut -> clk_1 = 0; 
    dut -> clk_2 = 0; 
    dut -> clk_3 = 0; 
    dut -> rstn = 1;
    while (main_time <= 10000) {
        if (main_time > 10 && main_time < 110)
            dut -> rstn = 0;
        else if ( main_time > 1000) 
	    dut->clken = 1;
	else
            dut -> rstn = 1;
        // VL_PRINTF("toggle clock ...\n");
        dut->clk_1 = (~ dut->clk_1) & 0x1;
        dut->clk_2 = (~ dut->clk_2) & 0x1;
        dut->clk_3 = (~ dut->clk_3) & 0x1;
        dut->eval();
        
        #if VM_TRACE
            if (tfp) tfp->dump(main_time);
        #endif
        main_time = main_time + 10;
    }
    dut->final();
    
    #if VM_TRACE
        if (tfp) { tfp->close(); tfp = NULL; }
    #endif
    
    #if VM_COVERAGE
        Verilated::mkdir("logs");
        VerilatedCov::write("logs/coverage.dat");
    #endif
    
    delete dut; dut = NULL;
    exit(0);
}
