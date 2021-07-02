#! /usr/bin/python3
import fileinput, sys

sys.stderr.write("reminder: this script takes input from stdin\n")
parseState = "idle"
inPageFault = 0
CSRs = {}
pageFaultCSRs = {}
regs = {}
pageFaultRegs = {}
instrs = {}

def printPC(l):
    global parseState, inPageFault, CSRs, pageFaultCSRs, regs, pageFaultCSRs, instrs
    if not inPageFault:
        inst = l.split()
        if len(inst) > 3:
            print(f'=> {inst[1]}:\t{inst[2]} {inst[3]}')
        else:
            print(f'=> {inst[1]}:\t{inst[2]}')
        print(f'{inst[0]} 0x{inst[1]}')

def printCSRs():
    global parseState, inPageFault, CSRs, pageFaultCSRs, regs, pageFaultCSRs, instrs
    if not inPageFault:
        for (csr,val) in CSRs.items():
            print('{}{}{:#x}  {}'.format(csr, ' '*(15-len(csr)), val, val))
        print('-----')

def parseCSRs(l):
    global parseState, inPageFault, CSRs, pageFaultCSRs, regs, pageFaultCSRs, instrs
    if l.strip() and (not l.startswith("Disassembler")) and (not l.startswith("Please")):
        if l.startswith(' x0/zero'):
            parseState = "regFile"
            instr = instrs[CSRs["pc"]]
            printPC(instr)
            parseRegs(l)
        else:
            csr = l.split()[0]
            val = int(l.split()[1],16)
            if inPageFault:
                # Not sure if these CSRs should be updated or not during page fault.
                if l.startswith("mstatus") or l.startswith("mepc") or l.startswith("mcause") or l.startswith("mtval") or l.startswith("sepc") or l.startswith("scause") or l.startswith("stval"):
                    # We do update some CSRs
                    CSRs[csr] = val
                else:
                    # Others we preserve until changed later
                    pageFaultCSRs[csr] = val
            elif pageFaultCSRs and (csr in pageFaultCSRs):
                if (val != pageFaultCSRs[csr]):
                    del pageFaultCSRs[csr]
                    CSRs[csr] = val
            else:
                CSRs[csr] = val

def parseRegs(l):
    global parseState, inPageFault, CSRs, pageFaultCSRs, regs, pageFaultCSRs, instrs
    if "mcounteren" in l:
        printCSRs()
        # New non-disassembled instruction
        parseState = "CSRs"
        parseCSRs(l)
    elif l.startswith('--------'):
        # End of disassembled instruction
        printCSRs()
        parseState = "idle"
    else:
        s = l.split()
        for i in range(0,len(s),2):
            if '/' in s[i]:
                reg = s[i].split('/')[1]
                val = int(s[i+1], 16)
                if inPageFault:
                    pageFaultRegs[reg] = val
                else:
                    if pageFaultRegs and (reg in pageFaultRegs):
                        if (val != pageFaultRegs[reg]):
                            del pageFaultRegs[reg]
                            regs[reg] = val
                    else:
                        regs[reg] = val
                    val = regs[reg]
                    print('{}{}{:#x}  {}'.format(reg, ' '*(15-len(reg)), val, val))
            else:
                sys.stderr.write("Whoops. Expected a list of reg file regs; got:\n"+l)

#############
# Main Code #
#############
for l in fileinput.input():
    if l.startswith('qemu-system-riscv64: QEMU: Terminated via GDBstub'):
        break
    elif l.startswith('IN:'):
        # New disassembled instr
        parseState = "instr"
    elif (parseState == "instr") and l.startswith('0x'):
        if "out of bounds" in l:
            sys.stderr.write("Detected QEMU page fault error\n")
            inPageFault = 1
        else: 
            inPageFault = 0
            adr = int(l.split()[0][2:-1], 16)
            instrs[adr] = l
        parseState = "CSRs"
    elif parseState == "CSRs":
        parseCSRs(l)
    elif parseState == "regFile":
        parseRegs(l)
