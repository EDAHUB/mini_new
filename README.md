# mini_new README

# instal veriltor
sudo apt-get install verilator

# compile & run & dump waveform
make -C build vrlt

# compare waveform
tar zxvf waveform/vrlt_dump.vcd.tar.gz
diff build/vrlt_dump.vcd vrlt_dump.vcd

