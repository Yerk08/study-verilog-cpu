# study-verilog-cpu
```
VCD info: dumpfile cpu_waves.vcd opened for output.
Time: 03 | PC0: 00 | AC0: 00 | Instr: 00000000
Time: 05 | PC0: 01 | AC0: 00 | Instr: 11000000
Time: 07 | PC0: 02 | AC0: 00 | Instr: 00000001
Time: 09 | PC0: 03 | AC0: 00 | Instr: 11000100
Time: 11 | PC0: 04 | AC0: 00 | Instr: 00000000
Time: 13 | PC0: 04 | AC0: 00 | Instr: 00000000
Time: 15 | PC0: 05 | AC0: 00 | Instr: 10000001
Time: 17 | PC0: 06 | AC0: 00 | Instr: 11000001
Time: 19 | PC0: 07 | AC0: 01 | Instr: 00000001
Time: 21 | PC0: 08 | AC0: 01 | Instr: 00000001
Time: 23 | PC0: 09 | AC0: 01 | Instr: 10000001
Time: 25 | PC0: 0a | AC0: 01 | Instr: 00000101
Time: 27 | PC0: 0b | AC0: 02 | Instr: 11001000
Time: 29 | PC0: 0c | AC0: 02 | Instr: 00000000
Time: 31 | PC0: 08 | AC0: 02 | Instr: 00000000
Time: 33 | PC0: 09 | AC0: 02 | Instr: 10000001
Time: 35 | PC0: 0a | AC0: 02 | Instr: 00000101
Time: 37 | PC0: 0b | AC0: 03 | Instr: 11001000
Time: 39 | PC0: 0c | AC0: 03 | Instr: 00000000
Time: 41 | PC0: 08 | AC0: 03 | Instr: 00000000
Time: 43 | PC0: 09 | AC0: 03 | Instr: 10000001
Time: 45 | PC0: 0a | AC0: 03 | Instr: 00000101
Time: 47 | PC0: 0b | AC0: 04 | Instr: 11001000
Time: 49 | PC0: 0c | AC0: 04 | Instr: 00000000
Time: 51 | PC0: 08 | AC0: 04 | Instr: 00000000
Time: 53 | PC0: 09 | AC0: 04 | Instr: 10000001
Time: 55 | PC0: 0a | AC0: 04 | Instr: 00000101
Time: 57 | PC0: 0b | AC0: 05 | Instr: 11001000
Time: 59 | PC0: 0c | AC0: 05 | Instr: 00000000
Time: 61 | PC0: 08 | AC0: 05 | Instr: 00000000
Memory dump complete.
main.sv:251: $finish called at 61 (1s)
PC:00 | DM[AC=0] is zero => PC += 1
PC:01 | DM[AC=0] += 1
PC:02 | DM[AC=0] != 0 => PC = 4
PC:04 | AC += 1
PC:05 | DM[AC=1] is zero => PC += 1
PC:06 | DM[AC=1] += 1
PC:07 | DM[AC=1] += 1
PC:08 | AC += 1
PC:09 | DM[AC=2] += 5
PC:0A | DM[AC=2] != 0 => PC = 8
PC:08 | AC += 1
PC:09 | DM[AC=3] += 5
PC:0A | DM[AC=3] != 0 => PC = 8
PC:08 | AC += 1
PC:09 | DM[AC=4] += 5
PC:0A | DM[AC=4] != 0 => PC = 8
PC:08 | AC += 1
PC:09 | DM[AC=5] += 5
PC:0A | DM[AC=5] != 0 => PC = 8
PC:08 | AC += 1
Addr     | Golden   | Verilog 
------------------------------
0x00     | 0x01     | 0x01      (OK)
0x01     | 0x02     | 0x02      (OK)
0x02     | 0x05     | 0x05      (OK)
0x03     | 0x05     | 0x05      (OK)
0x04     | 0x05     | 0x05      (OK)
0x05     | 0x05     | 0x05      (OK)

SUCCESS
```
