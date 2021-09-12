
default: vrlt


run:
	obj_dir/Vdut_top +trace 

vrlt:
	time verilator  --cc --exe -O3 --trace --debugi 2 --dump-treei 0 --top-module dut_top ../rtl/dut.v ../tb/vrlt_main.cpp -CFLAGS "-DVL_DEBUG"
	make -C obj_dir -f Vdut_top.mk -j
	time obj_dir/Vdut_top +trace  

