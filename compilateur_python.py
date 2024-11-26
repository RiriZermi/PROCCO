import sys


instruction_set = {
    "NOP": "00000",   # No operation
    "ADD": "00001",   # Addition
    "SUB": "00010",   # Subtraction
    "AND": "00011",# Bitwise AND
    "OR": "00100", # Bitwise OR
    "XOR": "00101",# Bitwise XOR
    "SLL": "00110",   # Shift Left Logical
    "SRL": "00111",   # Shift Right Logical
    "OUT": "01000",   # Output
    "ADDI": "01001",  # Addition Immediate
    "ANDI": "01010",  # AND Immediate
    "ORI": "01011",   # OR Immediate
    "LW": "01100",    # Load Word
    "SW": "01101",    # Store Word
    "J": "01110",     # Jump
    "JEQ": "01111",   # Jump if Equal
    "JNE": "10000",   # Jump if Not Equal
    "JCA": "10001",   # Jump if Carry Active
    "JNC": "10010",   # Jump if No Carry
    "HALT": "11111",  # Stop the processor
    "SUBI": "10011",  # Subtract Immediate
    "LIS"  : "10100", # Load Signed Immediate in Register
    "LIU" : "10101",  #Load Unsigned Immediate in Register
    "JZE" : "10110",  #Jump if Zero Active
    "JNZ" : "10111",   #Jump if No Zero
    "NOT" : "11000",   #Inverse
    "CIN" : "11001",   #Input from user
    "J_USER": "11010"  #Jump if user confirm
}
def parse_line(line):
    parts = line.split()
    instruction = parts[0]
    operands = parts[1:] if len(parts) > 1 else []
    return instruction, operands
    
def assembly_line(instruction, operands, symbol_table):
    opcode = instruction_set.get(instruction, "ERROR")
    if (opcode == "ERROR"):
        print(f"Instruction {instruction} don't exist ;'( \nHere the available list of instruction : {list(instruction_set.keys())} ")
        exit()
        
    if (instruction == "ADD" or
        instruction == "SUB" or
        instruction == "AND" or
        instruction == "OR" or
        instruction == "XOR" or
        instruction == "NOT_op" or
        instruction == "OUT" or
        instruction == "CIN"):
                
        binary_operands = [
        f"{int(op[1:]):04b}"
        for op in operands
        ]

            
    
    elif (instruction == "ADDI" or
        instruction == "SUBI" or
        instruction == "ORI" or
        instruction == "SLL" or
        instruction == "SRL" or
        instruction == "ANDI" or 
        instruction == "JEQ" or
        instruction == "JNE"
        ):
        binary_operands = []
        for op in operands:
            if (op[0] == 'R'):
                binary_operands.append(f"{int(op[1:]):04b}")
            else:
                if op in symbol_table:
                    op = symbol_table[op]                
                #int_op = (1 << 23) + value if value < 0 else value                
                binary_operands.append(f"{int(op,0):019b}")
                
    elif (instruction == "SW" or
        instruction == "LW"):
        binary_operands = []
        for op in operands:
            if (op[0] == 'R'):
                binary_operands.append(f"{int(op[1:]):04b}")
            else :
                imm, reg = op[:-1].split('(')  #we don't have the last parenthesis and we cut at the first parenthesis
                if imm in symbol_table:
                    imm = symbol_table[imm]
                binary_operands.append(f"{int(reg[1:]):04b}" + f"{int(imm,0):019b}")
    
    elif (instruction == "J" or instruction == "J_USER"):
        op = operands[0] #only one operand
        binary_operands=[]
        imm, reg = op[:-1].split('(')  #we don't have the last parenthesis and we cut at the first parenthesis
        if imm in symbol_table:
            imm = symbol_table[imm]    
        binary_operands.append(f"{int(reg[1:]):04b}"+ f"{int(imm,0):023b}")
        
        
    elif (instruction == "JCA" or
          instruction == "JNC" or
          instruction == "JZE" or
          instruction == "JNZ"):

        op = operands[0] #only one operand
        binary_operands=[]
        imm = op
        if imm in symbol_table:
            imm = symbol_table[imm]
        binary_operands.append(f"{int(imm,0):027b}")
        
        
    elif (instruction == "LIS" or instruction == "LIU"):
        binary_operands = []
        for op in operands:
            if (op[0] == 'R'):
                binary_operands.append(f"{int(op[1:]):04b}")
            else:
                value = int(op,0)
                int_op = (1 << 23) + value if value < 0 else value
                binary_operands.append(f"{int_op:023b}")
                
    else :# HALT
        binary_operands=[] #dont care
    

    
    return fill_instruction(opcode + "" + "".join(binary_operands))


def fill_instruction(s):
    
    return s.ljust(32,"0")
    

def value_in_memory(op):
    int_op = int(op[1:],0)
    
    return f"{int_op:032b}"
    
def handle_org(address, current_address, binary_list):
    while current_address < address:
        binary_list.append("00000000000000000000000000000000")  # NOP
        current_address += 1
    return current_address
    
def parse_labels(lines):
    symbol_table = {}
    address = 0
    
    
    for line in lines:
        line = line.split(';')[0] #remove commentprint(line)
        line = line.strip() #remove space before and after char      
        if not line:
            continue #ignore empty line   
        if line.endswith(":"):  #label
            label_name = line[0:-1] #remove :  
            if label_name in symbol_table:
                raise ValueError(f"Label déjà défini : {label_name}")
            symbol_table[label_name] = str(address)
        elif line.startswith("ORG"):  # ORG Dir
                _, addr = line.split()
                address = int(addr, 0)
                
        else:
            address += 1  
    
    
    return symbol_table
def generate_binary(filename):    
    with open(filename,'r') as f:
        lines = f.readlines()
        binary_list=[]
        current_address = 0
        symbol_table = parse_labels(lines)
        print(symbol_table)
        for line in lines:
       
            line = line.split(';')[0] #erase commentary
            line = line.strip()
            if not line or line.endswith(':'):
                continue #ignore empty line and labels

            if line.startswith("ORG"):  # ORG Dir
                _, addr = line.split()
                target_address = int(addr, 0)  
                current_address = handle_org(target_address, current_address, binary_list)
            
            elif line.startswith("!"):  # Brut value in memory
                binary = value_in_memory(line)
                binary_list.append(binary)
                current_address += 1
            
            elif line.endswith(":"): #LABEL
                continue
            else:  # Instruction standard
                inst, op = parse_line(line)
                binary = assembly_line(inst, op, symbol_table)
                binary_list.append(binary)
                current_address += 1
    
    with open("./include/RAM.bin",'w') as f:
        for binary in binary_list:
            f.write(binary)
            f.write('\n')
    
    print("Successfully write .bin")
    return 0
    
def main():
    # Vérifie si un fichier a été donné en argument
    if len(sys.argv) < 2:
        print("Usage: python script.py <filename>")
        sys.exit(1)  # Quitte le programme avec un code d'erreur
    
    print(sys.argv[0])
    # Récupère le nom du fichier
    filename = sys.argv[1]

    # Lire le fichier
    try:
        with open(filename, 'r') as file:
            content = file.read()
    except FileNotFoundError:
        print(f"Erreur : le fichier '{filename}' est introuvable.")
    except Exception as e:
        print(f"Une erreur est survenue : {e}")
    
    generate_binary(filename)    
        
if __name__ == "__main__":
    main()