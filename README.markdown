
# Procco Processor
## Table of Contents
- [Introduction](#introduction)
- [Architecture](#architecture)
- [Microarchitecture](#microarchitecture)
- [Python Compiler &  Assembly Language](#python-compiler-and-assembly-language)
- [Notes](#notes)

## Introduction

This processor is a modified implementation of the processor presented by Ben Eater in his video series (https://www.youtube.com/watch?v=HyznrdDSSGM&list=PLowKtXNTBypGqImE405J2565dvjafglHU ). It is implementable on FPGA and presents instructions to be able to allow interaction with a user.

## Architecture

The Procco processor employs a custom instruction set with 32 unique operations. Each instruction is represented by a 5-bit opcode, allowing for a broad range of functionalities:

| Instruction | Opcode | Description                            |  Operation
|-------------|--------|-----------------------------------------|---------------|
| NOP         | 00000  | No operation                            |     
| ADD         | 00001  | Addition                                | rd <= rs + rt
| SUB         | 00010  | Subtraction                             | rd <= rs - rt
| AND         | 00011  | Bitwise AND                             | rd <= rs & rt
| OR          | 00100  | Bitwise OR                              | rd <= rs \| rt
| XOR         | 00101  | Bitwise XOR                             | rd <= rs ^ rt
| SLL         | 00110  | Shift Left Logical                      | rd <= rs << Imm
| SRL         | 00111  | Shift Right Logical                     | rd <= rs >> Imm
| OUT         | 01000  | Output on 7 segments display            | OUT(rs)
| ADDI        | 01001  | Addition Immediate                      | rd <= rs + Imm
| SUBI        | 10011  | Subtract Immediate                      | rd <= rs - Imm
| ANDI        | 01010  | AND Immediate                           | rd <= rs & Imm
| ORI         | 01011  | OR Immediate                            | rd <= rs \| Imm
| LW          | 01100  | Load Word                               | rt <= mem[ Imm + rs ]
| SW          | 01101  | Store Word                              | mem[Imm + rs) <= rt
| J           | 01110  | Jump                                    | PC <= Imm + rs
| JEQ         | 01111  | Jump if Equal                           | PC <= Imm if rs = rt
| JNE         | 10000  | Jump if Not Equal                       | PC <= Imm if rs ≠ rt
| JCA         | 10001  | Jump if Carry Active                    | PC <= Imm if Carry_flag = 1
| JNC         | 10010  | Jump if No Carry                        | PC <= Imm if Carry_flag = 0
| JZE         | 10110  | Jump if Zero Active                     | PC <= Imm if Zero_flag = 1
| JNZ         | 10111  | Jump if No Zero                         | PC <= Imm if Zero_flag = 0
| HALT        | 11111  | Stop the processor                      |
| LIS         | 10100  | Load Signed Immediate in Register       | rd <= Signed(Imm)
| LIU         | 10101  | Load Unsigned Immediate in Register     | rd <= Unsigned(Imm)
| NOT         | 11000  | Inverse (Bitwise NOT)                   | rd <= ~Imm
| CIN         | 11001  | Wait until user_confirm = 1 and store user_value in rd  | rd <= User_value 
| J_USER      | 11010  | Jump if user confirm_value = 1, if not wait                 | PC <= Imm + Rs if user_confirm = 1

## Microarchitecture
###  Parameters
-    The system has 16 addressable registers, with **R0** reserved as a constant value of 0 by convention, and **R1** designated for temporary calculations.
-   The RAM can address up to **2^10** locations, with the Memory Address Register (MAR) being encoded using 10 bits (this can be adjusted as needed).
### Design
![Micro_Architecture](https://i.imgur.com/spo2W1G.png)

## Python Compiler And Assembly Language

A Python-based assembler/compiler has been developed for Procco, allowing developers to write assembly code and convert it into binary instructions compatible with the processor. The compiler supports the full instruction set, facilitating rapid development and testing.

### Assembly
| Instruction | Syntaxe |
|-------------|---------|
| `NOP`       | `NOP` |
| `ADD`       | `ADD RD RS RT` |
| `SUB`       | `SUB RD RS RT` |
| `AND`       | `AND RD RS RT` |
| `OR`        | `OR RD RS RT` |
| `XOR`       | `XOR RD RS RT` |
| `SLL`       | `SLL RD RS imm` |
| `SRL`       | `SRL RD RS imm` |
| `OUT`       | `OUT RD` |
| `ADDI`      | `ADDI RD RS imm` |
| `SUBI`      | `SUBI RD RS imm` |
| `ANDI`      | `ANDI RD RS imm` |
| `ORI`       | `ORI RD RS imm` |
| `LW`        | `LW RS offset(RT)` |
| `SW`        | `SW RS offset(RT)` |
| `J`         | `J target(RS)` |
| `JEQ`       | `JEQ RS RT target` |
| `JNE`       | `JNE RS RT target` |
| `JCA`       | `JCA target(RS)` |
| `JNC`       | `JNC target(RS)` |
| `JZE`       | `JZE RS target` |
| `JNZ`       | `JNZ RS target` |
| `HALT`      | `HALT` |
| `LIS`       | `LIS RD imm` |
| `LIU`       | `LIU RD imm` |
| `NOT`       | `NOT RD RS` |
| `CIN`       | `CIN RD` |
| `J_USER`    | `J_USER target` |

### Labels

In the compiler, labels can be used to create jump targets or mark specific locations in the code. Labels are defined by a name followed by a colon, and they can be used with jump instructions or anywhere an address is needed.

#### Example of label usage:
```assembly
START:
    ADD R1 R2 R3  ; Perform addition
    JUMP TO_NEXT     ; Jump to the label TO_NEXT
TO_NEXT:
    HALT              ; Halt the execution
```
### ORG Directive
The `ORG` directive is used to specify the starting address for a given section of code or data. This allows for fine control over memory allocation, enabling you to position code or data at a specific address.

#### Example of ORG usage:
```assembly
ORG 0x1000 ; Start this section of code at memory address 0x1000 
	ADD R1 R2 R3
```

### Immediate

Immediates can be written in several formats, including:

-   **Decimal**: Simply write the value (e.g., `20`).
-   **Hexadecimal**: Prefix the value with `0x` (e.g., `0x14` for 20 in hexadecimal).
-   **Binary**: Prefix the value with `0b` (e.g., `0b10100` for 20 in binary).
-   **Octal**: Prefix the value with `0o` (e.g., `0o24` for 20 in octal).

#### Immediate Example
```assembly 
ADDI R1 R2 20    ; Add immediate 20 (decimal) to R2, store result in R1
ADDI R1 R2 0x14  ; Add immediate 0x14 (hexadecimal) to R2, store result in R1
ADDI R1 R2 0b10100 ; Add immediate 0b10100 (binary) to R2, store result in R1
ADDI R1 R2 0o24  ; Add immediate 0o24 (octal) to R2, store result in R1
```
### Assembly to .bin
``` bash
python ./compilator.py ..../ASSEMBLY.txt
```
This will write in binary in  DATA/RAM.bin 


## Notes

In $readmemb in src/RAM.sv, you need to redefine the path of DATA/RAM.bin.
