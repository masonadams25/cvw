#! /usr/bin/python3
import sys

################
# Helper Funcs #
################

def tokenize(string):
    tokens = []
    token = ''
    whitespace = 0
    prevWhitespace = 0
    for char in string:
        prevWhitespace = whitespace
        whitespace = char in ' \t\n'
        if (whitespace):
            if ((not prevWhitespace) and (token != '')): 
                tokens.append(token)
            token = ''
        else:
            token = token + char
    return tokens

#############
# Main Code #
#############
print("Begin parsing state.")

# Parse Args
if len(sys.argv) != 2:
    sys.exit('Error parseState.py expects 1 arg:\n parseState.py <path_to_checkpoint_dir>')
outDir = sys.argv[1]
stateGDBpath = outDir+'/intermediate-outputs/stateGDB1K.txt'
if not os.path.exists(stateGDBpath):
    sys.exit('Error input file '+stateGDBpath+'not found')

listCSRs = ['hpmcounter','pmpcfg','pmpaddr']
singleCSRs = ['mip','mie','mscratch','mcause','mepc','mtvec','medeleg','mideleg','mcounteren','sscratch','scause','sepc','stvec','sedeleg','sideleg','scounteren','satp','mstatus']

# Initialize List CSR files to empty
# (because later we'll open them in append mode)
for csr in listCSRs:
    outFileName = 'checkpoint-'+csr.upper() 
    outFile = open(outDir+outFileName, 'w')
    outFile.close()

# Initial State for Main Loop
currState = 'regFile'
regFileIndex = 0
outFileName = 'checkpoint-regfile.txt'
outFile = open(outDir+outFileName, 'w')

# Main Loop
with open(stateGDBpath, 'r') as stateGDB:
    for line in stateGDB:
        line = tokenize(line)
        name = line[0]
        val = line[1][2:]
        if (currState == 'regFile'):
            if (regFileIndex == 0 and name != 'zero'):
                print('Whoops! Expected regFile registers to come first, starting with zero')
                exit(1)
            outFile.write(val+'\n')
            regFileIndex += 1
            if (regFileIndex == 32):
                outFile.close()
                currState = 'CSRs'
        elif (currState == 'CSRs'):
            if name in singleCSRs: 
                outFileName = 'checkpoint-'+name.upper() 
                outFile = open(outDir+outFileName, 'w')
                outFile.write(val+'\n')
                outFile.close()
            elif name.strip('0123456789') in listCSRs:
                outFileName = 'checkpoint-'+name.upper().strip('0123456789')
                outFile = open(outDir+outFileName, 'a')
                outFile.write(val+'\n')
                outFile.close()
print("Finished parsing state!")
