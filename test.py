import subprocess
import os

def simulate_golden_model(program_hex):
    IM = [0] * 256
    DM = [0] * 256
    for i, val in enumerate(program_hex):
        IM[i] = val
    
    PC = 0
    AC = 0
    
    for _ in range(20):
        if PC >= 256: break
        
        D = IM[PC]
        
        if D == 0: # NOP
            PC = (PC + 1) & 0xFF
        elif (D & 0x80) == 0: # 0??????? -> DM[AC] += D[6:0]
            val = D & 0x7F
            print(f"PC:{PC:02X} | DM[AC={AC}] += {val}")
            DM[AC] = (DM[AC] + val) & 0xFF
            PC = (PC + 1) & 0xFF
        elif (D & 0xC0) == 0x80: # 10?????? -> AC += D[5:0]
            val = D & 0x3F
            print(f"PC:{PC:02X} | AC += {val}")
            AC = (AC + val) & 0xFF
            PC = (PC + 1) & 0xFF
        elif (D & 0xC0) == 0xC0: # 11?????? -> JNZ (Jump if DM[AC] != 0)
            val = D & 0x3F
            if DM[AC] != 0:
                print(f"PC:{PC:02X} | DM[AC={AC}] != 0 => PC = {val}")
                PC = (val) & 0xFF
            else:
                print(f"PC:{PC:02X} | DM[AC={AC}] is zero => PC += 1")
                PC = (PC + 1) & 0xFF
                
    return DM

def run_test():
    prog = [0xC0, 0x01, 0xC4, 0x00, 0x81, 0xC1, 0x01, 0x01, 0x81, 0x05, 0xC8]
    
    golden_dm = simulate_golden_model(prog)

    subprocess.run(["iverilog", "-o", "main.vvp", "main.sv"])
    subprocess.run(["vvp", "main.vvp"])

    if not os.path.exists("dm_final.mem"):
        print("Failute: File dm_final.mem not found!")
        return

    with open("dm_final.mem", "r") as f:
        verilog_dm = [int(line.strip(), 16) for line in f if line.strip()
                        if not "//" in line]

    print(f"{'Addr':<8} | {'Golden':<8} | {'Verilog':<8}")
    print("-" * 30)
    
    errors = 0
    for i in range(256):
        g_val = f"0x{golden_dm[i]:02X}"
        v_val = f"0x{verilog_dm[i]:02X}"
        addr  = f"0x{i:02X}"

        if golden_dm[i] != verilog_dm[i]:
            print(f"{addr:<8} | {g_val:<8} | {v_val:<8}  <-- MISMATCH")
            errors += 1
        elif golden_dm[i] != 0: 
            print(f"{addr:<8} | {g_val:<8} | {v_val:<8}  (OK)")

    if errors == 0:
        print("\nSUCCESS")
    else:
        print(f"\nFAILED: Found {errors} errors.")

if __name__ == "__main__":
    run_test()
