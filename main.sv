/*
module CPU_chip_simple (
    input [7:0]IM[255:0], // Instruction Memory
    inout [7:0]DM[255:0], // Data Memory
    input reset,
    input clk
);
    logic [7:0]PC; // Program Counter
    logic [7:0]AC; // Address Counter

    assign D = IM[PC];
    always @(posedge clk) begin
        if (reset) begin
            PC <= 0;
            AC <= 0;
        end else begin
            casez (D)
                8'b00000000: PC <= PC + 1;
                8'b0???????: begin
                    DM[AC] <= DM[AC] + D[6:0];
                    PC <= PC + 1;
                end
                8'b10??????: begin
                    AC <= AC + D[5:0];
                    PC <= PC + 1;
                end
                8'b11??????: PC <= (DM[AC] != 0) ? PC + D[5:0] : PC + 1;
                default: PC <= PC + 1;
            endcase
        end
    end
endmodule
*/


/*
module CPU_chip_conveyor (
    input [7:0]IM[255:0],  // Instruction Memory
    input [7:0]DML[255:0], // Data Memory Load
    output[7:0]DMS[255:0], // Data Memory Store
    input reset,
    input clk
);
    logic [7:0]PC0;  // Init PC
    logic [7:0]AC0;  // Init AC

    logic [7:0]MPC1; // IM[PC]
    logic [7:0]PC1;
    logic [7:0]AC1;

    logic [7:0]MPC2;
    logic [7:0]MAC2; // DM[AC]
    logic [7:0]PC2;
    logic [7:0]AC2;

    logic branch_reset; // when DM[AC] == 0
    logic AC0_write;    // need to reset AC1 & AC2

    always @(posedge clk) begin
        if (reset) begin
            PC0 <= 0;
            AC0 <= 0;
            MPC1 <= 0;
            MPC2 <= 0;
        end else begin
            branch_reset = 0;
            AC0_write = 0;
            
            casez (MPC2)
                8'b00000000: ;
                8'b0???????: DML[AC2] <= MAC2 + MPC2[6:0];
                8'b10??????: AC0_write = 1;
                8'b11??????: branch_reset = (MAC2 != 0);
                default: ;
            endcase

            if (branch_reset) begin
                PC0 <= PC2 + MPC2[5:0];
                MPC1 <= 8'b0;
                MPC2 <= 8'b0;
            end else begin
                PC0 <= PC0 + 1;

                MPC1 <= IM[PC0];
                PC1 <= PC0;
                if (AC0_write) begin
                    AC0 <= AC2 + MPC2[5:0];
                    AC1 <= AC2 + MPC2[5:0];
                end else begin
                    AC1 <= AC0;
                end

                MPC2 <= MPC1;
                MAC2 <= DML[AC1];
                PC2 <= PC1;
                AC2 <= AC1;
            end
        end
    end
endmodule
*/


module CPU_brainfck (
    output [7:0] im_addr,
    input  [7:0] im_data,

    output [7:0] dm_addr,
    output [7:0] dm_wdata,
    input  [7:0] dm_rdata,
    output       dm_we,    // Write Enable (1 - write, 0 - load)

    input reset,
    input clk
);
    logic [7:0]PC0;  // Init PC
    logic [7:0]AC0;  // Init AC

    logic [7:0]MPC1; // IM[PC]
    logic [7:0]PC1;
    logic [7:0]AC1;

    logic [7:0]MPC2;
    logic [7:0]MAC2; // DM[AC]
    logic [7:0]PC2;
    logic [7:0]AC2;

    logic branch_reset; // when DM[AC] == 0
    logic AC0_write;    // need to reset AC1 & AC2

    assign im_addr  = PC0;
    assign dm_addr  = AC1; 
    assign dm_wdata = dm_rdata + MPC2[6:0];
    assign dm_we    = (MPC2[7] == 0 && MPC2 != 8'b0);

    always @(posedge clk) begin
        if (reset) begin
            PC0 <= 0;
            AC0 <= 0;
            MPC1 <= 0;
            MPC2 <= 0;
        end else begin
            branch_reset = 0;
            AC0_write = 0;
            
            casez (MPC2)
                8'b00000000: ;
                8'b0???????: ;
                // already done in upper code (dm_wdata, dm_addr)
                8'b10??????: AC0_write = 1;
                8'b11??????: branch_reset = (dm_rdata != 0);
                // branch_reset=(MAC2==0) is wrong because
                // MAC2 could be changed to dm_wdata
                default: ;
            endcase

            if (branch_reset) begin
                PC0 <= MPC2[5:0];
                MPC1 <= 8'b0;
                MPC2 <= 8'b0;
                PC1 <= 8'b0;
                PC2 <= 8'b0;
                AC1 <= 8'b0;
                AC2 <= 8'b0;
            end else begin
                PC0 <= PC0 + 1;

                MPC1 <= im_data;
                PC1 <= PC0;
                if (AC0_write) begin
                    AC0 <= AC2 + MPC2[5:0];
                    AC1 <= AC2 + MPC2[5:0];
                end else begin
                    AC1 <= AC0;
                end

                MPC2 <= MPC1;
                MAC2 <= dm_rdata;
                PC2 <= PC1;
                AC2 <= AC1;
            end
        end
    end
endmodule



module CPU_tb;
    reg clk;
    reg reset;
    
    wire [7:0] im_addr, dm_addr, dm_wdata;
    wire [7:0] im_data, dm_rdata;
    wire dm_we;

    // Instruction memory emulation (ROM)
    reg [7:0] IM [0:255];
    // Data storage emulation (RAM)
    reg [7:0] DM [0:255];

    // Connecting RAM and ROM to processor
    CPU_brainfck dut (
        .im_addr(im_addr), .im_data(im_data),
        .dm_addr(dm_addr), .dm_wdata(dm_wdata), .dm_rdata(dm_rdata),
        .dm_we(dm_we), .reset(reset), .clk(clk)
    );

    // Reading from memory
    assign im_data = IM[im_addr];
    assign dm_rdata = DM[dm_addr];

    // Writing to memory
    always @(posedge clk) begin
        if (dm_we) DM[dm_addr] <= dm_wdata;
    end

    always #1 clk = ~clk;

    // Primary testing the chip
    initial begin
        $dumpfile("cpu_waves.vcd");
        $dumpvars(0, CPU_tb);
        for (integer i = 0; i < 256; i = i + 1) begin
            IM[i] = 0;
            DM[i] = 0;
        end

        // PROGRAM:
        IM[0] = 8'hC0; // JMP(DM[AC]) 0 [false]
        IM[1] = 8'h01; // DM[AC] += 1
        IM[2] = 8'hC4; // JMP(DM[AC]) 5 [true]
        IM[3] = 8'h00; // NOP
        IM[4] = 8'h81; // AC += 1
        IM[5] = 8'hC1; // JMP(DM[AC]) 1 [false]
        IM[6] = 8'h01; // DM[AC] += 1
        IM[7] = 8'h01; // DM[AC] += 1
        IM[8] = 8'h81; // AC += 1 [loop start]
        IM[9] = 8'h05; // DM[AC] += 5
        IM[10] = 8'hC8; // JMP(DM[AC]) 8 [true] - loop

        clk = 0;
        reset = 1;
        #2 reset = 0;

        repeat(30) begin
            @(posedge clk);
            $display("Time: %02t | PC0: %h | AC0: %h | Instr: %b", $time, dut.PC0, dut.AC0, dut.MPC1);
        end
        $writememh("dm_final.mem", DM); 
        $display("Memory dump complete.");
        $finish;
    end
endmodule
