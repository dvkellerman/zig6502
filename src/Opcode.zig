const std = @import("std");
const CPU = @import("CPU.zig").CPU;
const Instruction = @import("CPU.zig").Instruction;
const AddressingMode = @import("CPU.zig").AddressingMode;

pub const Opcode = struct {
    hex: u8,
    instruction: Instruction,
    bytes: u8,
    cycles: u8,
    mode: AddressingMode,
    flags: u8,

    pub fn by_hex(hex: u8) Opcode {
        for (Opcodes) |o| {
            if (o.hex == hex) {
                return o;
            }
        }
        return Opcodes[Opcodes.len - 1]; // NoOp
    }
};

const Opcodes = [_]Opcode{
    // BRK
    Opcode{ .hex = 0x00, .instruction = .BRK, .bytes = 1, .cycles = 7, .mode = .Implied, .flags = 0b00000100 },
    // Stack
    Opcode{ .hex = 0x48, .instruction = .PHA, .bytes = 1, .cycles = 3, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0x08, .instruction = .PHP, .bytes = 1, .cycles = 3, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0x68, .instruction = .PLA, .bytes = 1, .cycles = 4, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0x28, .instruction = .PLP, .bytes = 1, .cycles = 4, .mode = .Implied, .flags = 0b10000010 },
    Opcode{ .hex = 0x9A, .instruction = .TXS, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0xBA, .instruction = .TSX, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b00000000 },
    // ADC
    Opcode{ .hex = 0x69, .instruction = .ADC, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b11000011 },
    Opcode{ .hex = 0x65, .instruction = .ADC, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b11000011 },
    Opcode{ .hex = 0x75, .instruction = .ADC, .bytes = 2, .cycles = 4, .mode = .ZeroPageX, .flags = 0b11000011 },
    Opcode{ .hex = 0x6D, .instruction = .ADC, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b11000011 },
    Opcode{ .hex = 0x7D, .instruction = .ADC, .bytes = 3, .cycles = 4, .mode = .AbsoluteX, .flags = 0b11000011 },
    Opcode{ .hex = 0x79, .instruction = .ADC, .bytes = 3, .cycles = 4, .mode = .AbsoluteY, .flags = 0b11000011 },
    Opcode{ .hex = 0x61, .instruction = .ADC, .bytes = 2, .cycles = 6, .mode = .IndirectX, .flags = 0b11000011 },
    Opcode{ .hex = 0x71, .instruction = .ADC, .bytes = 2, .cycles = 5, .mode = .IndirectY, .flags = 0b11000011 },
    // SBC
    Opcode{ .hex = 0xE9, .instruction = .SBC, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b11000011 },
    Opcode{ .hex = 0xE5, .instruction = .SBC, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b11000011 },
    Opcode{ .hex = 0xF5, .instruction = .SBC, .bytes = 2, .cycles = 4, .mode = .ZeroPageX, .flags = 0b11000011 },
    Opcode{ .hex = 0xED, .instruction = .SBC, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b11000011 },
    Opcode{ .hex = 0xFD, .instruction = .SBC, .bytes = 3, .cycles = 4, .mode = .AbsoluteX, .flags = 0b11000011 },
    Opcode{ .hex = 0xF9, .instruction = .SBC, .bytes = 3, .cycles = 4, .mode = .AbsoluteY, .flags = 0b11000011 },
    Opcode{ .hex = 0xE1, .instruction = .SBC, .bytes = 2, .cycles = 6, .mode = .IndirectX, .flags = 0b11000011 },
    Opcode{ .hex = 0xF1, .instruction = .SBC, .bytes = 2, .cycles = 5, .mode = .IndirectY, .flags = 0b11000011 },
    // Store
    Opcode{ .hex = 0x85, .instruction = .STA, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b00000000 },
    Opcode{ .hex = 0x95, .instruction = .STA, .bytes = 2, .cycles = 4, .mode = .ZeroPageX, .flags = 0b00000000 },
    Opcode{ .hex = 0x8D, .instruction = .STA, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b00000000 },
    Opcode{ .hex = 0x9D, .instruction = .STA, .bytes = 3, .cycles = 5, .mode = .AbsoluteX, .flags = 0b00000000 },
    Opcode{ .hex = 0x99, .instruction = .STA, .bytes = 3, .cycles = 5, .mode = .AbsoluteY, .flags = 0b00000000 },
    Opcode{ .hex = 0x81, .instruction = .STA, .bytes = 2, .cycles = 6, .mode = .IndirectX, .flags = 0b00000000 },
    Opcode{ .hex = 0x91, .instruction = .STA, .bytes = 2, .cycles = 6, .mode = .IndirectY, .flags = 0b00000000 },
    Opcode{ .hex = 0x86, .instruction = .STX, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b00000000 },
    Opcode{ .hex = 0x96, .instruction = .STX, .bytes = 2, .cycles = 4, .mode = .ZeroPageY, .flags = 0b00000000 },
    Opcode{ .hex = 0x8E, .instruction = .STX, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b00000000 },
    Opcode{ .hex = 0x84, .instruction = .STY, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b00000000 },
    Opcode{ .hex = 0x94, .instruction = .STY, .bytes = 2, .cycles = 4, .mode = .ZeroPageX, .flags = 0b00000000 },
    Opcode{ .hex = 0x8C, .instruction = .STY, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b00000000 },
    // Load
    Opcode{ .hex = 0xA9, .instruction = .LDA, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b10000010 },
    Opcode{ .hex = 0xA5, .instruction = .LDA, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b10000010 },
    Opcode{ .hex = 0xB5, .instruction = .LDA, .bytes = 2, .cycles = 4, .mode = .ZeroPageX, .flags = 0b10000010 },
    Opcode{ .hex = 0xAD, .instruction = .LDA, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b10000010 },
    Opcode{ .hex = 0xBD, .instruction = .LDA, .bytes = 3, .cycles = 4, .mode = .AbsoluteX, .flags = 0b10000010 },
    Opcode{ .hex = 0xB9, .instruction = .LDA, .bytes = 3, .cycles = 4, .mode = .AbsoluteY, .flags = 0b10000010 },
    Opcode{ .hex = 0xA1, .instruction = .LDA, .bytes = 2, .cycles = 6, .mode = .IndirectX, .flags = 0b10000010 },
    Opcode{ .hex = 0xB1, .instruction = .LDA, .bytes = 2, .cycles = 5, .mode = .IndirectY, .flags = 0b10000010 },
    Opcode{ .hex = 0xA2, .instruction = .LDX, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b10000010 },
    Opcode{ .hex = 0xA6, .instruction = .LDX, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b10000010 },
    Opcode{ .hex = 0xB6, .instruction = .LDX, .bytes = 2, .cycles = 4, .mode = .ZeroPageY, .flags = 0b10000010 },
    Opcode{ .hex = 0xAE, .instruction = .LDX, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b10000010 },
    Opcode{ .hex = 0xBE, .instruction = .LDX, .bytes = 3, .cycles = 4, .mode = .AbsoluteY, .flags = 0b10000010 },
    Opcode{ .hex = 0xA0, .instruction = .LDY, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b10000010 },
    Opcode{ .hex = 0xA4, .instruction = .LDY, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b10000010 },
    Opcode{ .hex = 0xB4, .instruction = .LDY, .bytes = 2, .cycles = 4, .mode = .ZeroPageX, .flags = 0b10000010 },
    Opcode{ .hex = 0xAC, .instruction = .LDY, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b10000010 },
    Opcode{ .hex = 0xBC, .instruction = .LDY, .bytes = 3, .cycles = 4, .mode = .AbsoluteX, .flags = 0b10000010 },
    // Flags
    Opcode{ .hex = 0x18, .instruction = .CLC, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0x38, .instruction = .SEC, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0x58, .instruction = .CLI, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0x78, .instruction = .SEI, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0xB8, .instruction = .CLV, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0xD8, .instruction = .CLD, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0xF8, .instruction = .SED, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b00000000 },
    // Compare
    Opcode{ .hex = 0xC9, .instruction = .CMP, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b10000011 },
    Opcode{ .hex = 0xC5, .instruction = .CMP, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b10000011 },
    Opcode{ .hex = 0xD5, .instruction = .CMP, .bytes = 2, .cycles = 4, .mode = .ZeroPageX, .flags = 0b10000011 },
    Opcode{ .hex = 0xCD, .instruction = .CMP, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b10000011 },
    Opcode{ .hex = 0xDD, .instruction = .CMP, .bytes = 3, .cycles = 4, .mode = .AbsoluteX, .flags = 0b10000011 },
    Opcode{ .hex = 0xD9, .instruction = .CMP, .bytes = 3, .cycles = 4, .mode = .AbsoluteY, .flags = 0b10000011 },
    Opcode{ .hex = 0xC1, .instruction = .CMP, .bytes = 2, .cycles = 6, .mode = .IndirectX, .flags = 0b10000011 },
    Opcode{ .hex = 0xD1, .instruction = .CMP, .bytes = 2, .cycles = 5, .mode = .IndirectY, .flags = 0b10000011 },
    Opcode{ .hex = 0xE0, .instruction = .CPX, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b10000011 },
    Opcode{ .hex = 0xE4, .instruction = .CPX, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b10000011 },
    Opcode{ .hex = 0xEC, .instruction = .CPX, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b10000011 },
    Opcode{ .hex = 0xC0, .instruction = .CPY, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b10000011 },
    Opcode{ .hex = 0xC4, .instruction = .CPY, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b10000011 },
    Opcode{ .hex = 0xCC, .instruction = .CPY, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b10000011 },
    // INC
    Opcode{ .hex = 0xE6, .instruction = .INC, .bytes = 2, .cycles = 5, .mode = .ZeroPage, .flags = 0b10000010 },
    Opcode{ .hex = 0xF6, .instruction = .INC, .bytes = 2, .cycles = 6, .mode = .ZeroPageX, .flags = 0b10000010 },
    Opcode{ .hex = 0xEE, .instruction = .INC, .bytes = 3, .cycles = 6, .mode = .Absolute, .flags = 0b10000010 },
    Opcode{ .hex = 0xFE, .instruction = .INC, .bytes = 3, .cycles = 7, .mode = .AbsoluteX, .flags = 0b10000010 },
    Opcode{ .hex = 0xE8, .instruction = .INX, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b10000010 },
    Opcode{ .hex = 0xC8, .instruction = .INY, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b10000010 },
    // Transfer
    Opcode{ .hex = 0xAA, .instruction = .TAX, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b10000010 },
    Opcode{ .hex = 0x8A, .instruction = .TXA, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b10000010 },
    Opcode{ .hex = 0xA8, .instruction = .TAY, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b10000010 },
    Opcode{ .hex = 0x98, .instruction = .TYA, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b10000010 },
    // Decrement
    Opcode{ .hex = 0xC6, .instruction = .DEC, .bytes = 2, .cycles = 5, .mode = .ZeroPage, .flags = 0b10000010 },
    Opcode{ .hex = 0xD6, .instruction = .DEC, .bytes = 2, .cycles = 6, .mode = .ZeroPageX, .flags = 0b10000010 },
    Opcode{ .hex = 0xCE, .instruction = .DEC, .bytes = 3, .cycles = 6, .mode = .Absolute, .flags = 0b10000010 },
    Opcode{ .hex = 0xDE, .instruction = .DEC, .bytes = 3, .cycles = 7, .mode = .AbsoluteX, .flags = 0b10000010 },
    Opcode{ .hex = 0xCA, .instruction = .DEX, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b10000010 },
    Opcode{ .hex = 0x88, .instruction = .DEY, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b10000010 },
    // Bitwise
    Opcode{ .hex = 0x4A, .instruction = .LSR, .bytes = 1, .cycles = 2, .mode = .Accumulator, .flags = 0b00000011 },
    Opcode{ .hex = 0x46, .instruction = .LSR, .bytes = 2, .cycles = 5, .mode = .ZeroPage, .flags = 0b00000011 },
    Opcode{ .hex = 0x56, .instruction = .LSR, .bytes = 2, .cycles = 6, .mode = .ZeroPageX, .flags = 0b00000011 },
    Opcode{ .hex = 0x4E, .instruction = .LSR, .bytes = 3, .cycles = 6, .mode = .Absolute, .flags = 0b00000011 },
    Opcode{ .hex = 0x5E, .instruction = .LSR, .bytes = 3, .cycles = 7, .mode = .AbsoluteX, .flags = 0b00000011 },
    Opcode{ .hex = 0x2A, .instruction = .ROL, .bytes = 1, .cycles = 2, .mode = .Accumulator, .flags = 0b10000011 },
    Opcode{ .hex = 0x26, .instruction = .ROL, .bytes = 2, .cycles = 5, .mode = .ZeroPage, .flags = 0b10000011 },
    Opcode{ .hex = 0x36, .instruction = .ROL, .bytes = 2, .cycles = 6, .mode = .ZeroPageX, .flags = 0b10000011 },
    Opcode{ .hex = 0x2E, .instruction = .ROL, .bytes = 3, .cycles = 6, .mode = .Absolute, .flags = 0b10000011 },
    Opcode{ .hex = 0x3E, .instruction = .ROL, .bytes = 3, .cycles = 7, .mode = .AbsoluteX, .flags = 0b10000011 },
    Opcode{ .hex = 0x6A, .instruction = .ROR, .bytes = 1, .cycles = 2, .mode = .Accumulator, .flags = 0b10000011 },
    Opcode{ .hex = 0x66, .instruction = .ROR, .bytes = 2, .cycles = 5, .mode = .ZeroPage, .flags = 0b10000011 },
    Opcode{ .hex = 0x76, .instruction = .ROR, .bytes = 2, .cycles = 6, .mode = .ZeroPageX, .flags = 0b10000011 },
    Opcode{ .hex = 0x6E, .instruction = .ROR, .bytes = 3, .cycles = 6, .mode = .Absolute, .flags = 0b10000011 },
    Opcode{ .hex = 0x7E, .instruction = .ROR, .bytes = 3, .cycles = 7, .mode = .AbsoluteX, .flags = 0b10000011 },
    Opcode{ .hex = 0x49, .instruction = .EOR, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b00000011 },
    Opcode{ .hex = 0x45, .instruction = .EOR, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b00000011 },
    Opcode{ .hex = 0x55, .instruction = .EOR, .bytes = 2, .cycles = 4, .mode = .ZeroPageX, .flags = 0b00000011 },
    Opcode{ .hex = 0x4D, .instruction = .EOR, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b00000011 },
    Opcode{ .hex = 0x5D, .instruction = .EOR, .bytes = 3, .cycles = 4, .mode = .AbsoluteX, .flags = 0b00000011 },
    Opcode{ .hex = 0x59, .instruction = .EOR, .bytes = 3, .cycles = 4, .mode = .AbsoluteY, .flags = 0b00000011 },
    Opcode{ .hex = 0x01, .instruction = .EOR, .bytes = 2, .cycles = 6, .mode = .IndirectX, .flags = 0b00000011 },
    Opcode{ .hex = 0x11, .instruction = .EOR, .bytes = 2, .cycles = 5, .mode = .IndirectY, .flags = 0b00000011 },
    Opcode{ .hex = 0x24, .instruction = .BIT, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b00000010 },
    Opcode{ .hex = 0x2C, .instruction = .BIT, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b00000010 },

    Opcode{ .hex = 0x0A, .instruction = .ASL, .bytes = 1, .cycles = 2, .mode = .Accumulator, .flags = 0b10000011 },
    Opcode{ .hex = 0x06, .instruction = .ASL, .bytes = 2, .cycles = 5, .mode = .ZeroPage, .flags = 0b10000011 },
    Opcode{ .hex = 0x16, .instruction = .ASL, .bytes = 2, .cycles = 6, .mode = .ZeroPageX, .flags = 0b10000011 },
    Opcode{ .hex = 0x0E, .instruction = .ASL, .bytes = 3, .cycles = 6, .mode = .Absolute, .flags = 0b10000011 },
    Opcode{ .hex = 0x1E, .instruction = .ASL, .bytes = 3, .cycles = 7, .mode = .AbsoluteX, .flags = 0b10000011 },

    Opcode{ .hex = 0x29, .instruction = .AND, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b10000010 },
    Opcode{ .hex = 0x25, .instruction = .AND, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b10000010 },
    Opcode{ .hex = 0x35, .instruction = .AND, .bytes = 2, .cycles = 4, .mode = .ZeroPageX, .flags = 0b10000010 },
    Opcode{ .hex = 0x2D, .instruction = .AND, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b10000010 },
    Opcode{ .hex = 0x3D, .instruction = .AND, .bytes = 3, .cycles = 4, .mode = .AbsoluteX, .flags = 0b10000010 },
    Opcode{ .hex = 0x39, .instruction = .AND, .bytes = 3, .cycles = 4, .mode = .AbsoluteY, .flags = 0b10000010 },
    Opcode{ .hex = 0x21, .instruction = .AND, .bytes = 2, .cycles = 6, .mode = .IndirectX, .flags = 0b10000010 },
    Opcode{ .hex = 0x31, .instruction = .AND, .bytes = 2, .cycles = 5, .mode = .IndirectY, .flags = 0b10000010 },
    Opcode{ .hex = 0x09, .instruction = .ORA, .bytes = 2, .cycles = 2, .mode = .Immediate, .flags = 0b10000010 },
    Opcode{ .hex = 0x05, .instruction = .ORA, .bytes = 2, .cycles = 3, .mode = .ZeroPage, .flags = 0b10000010 },
    Opcode{ .hex = 0x15, .instruction = .ORA, .bytes = 2, .cycles = 4, .mode = .ZeroPageX, .flags = 0b10000010 },
    Opcode{ .hex = 0x0D, .instruction = .ORA, .bytes = 3, .cycles = 4, .mode = .Absolute, .flags = 0b10000010 },
    Opcode{ .hex = 0x1D, .instruction = .ORA, .bytes = 3, .cycles = 4, .mode = .AbsoluteX, .flags = 0b10000010 },
    Opcode{ .hex = 0x19, .instruction = .ORA, .bytes = 3, .cycles = 4, .mode = .AbsoluteY, .flags = 0b10000010 },
    Opcode{ .hex = 0x01, .instruction = .ORA, .bytes = 2, .cycles = 6, .mode = .IndirectX, .flags = 0b10000010 },
    Opcode{ .hex = 0x11, .instruction = .ORA, .bytes = 2, .cycles = 5, .mode = .IndirectY, .flags = 0b10000010 },

    // Sub-routine and interupts
    Opcode{ .hex = 0x20, .instruction = .JSR, .bytes = 3, .cycles = 6, .mode = .Absolute, .flags = 0b00000000 },
    Opcode{ .hex = 0x4C, .instruction = .JMP, .bytes = 3, .cycles = 3, .mode = .Absolute, .flags = 0b00000000 },
    Opcode{ .hex = 0x6C, .instruction = .JMP, .bytes = 3, .cycles = 5, .mode = .Indirect, .flags = 0b00000000 },
    Opcode{ .hex = 0x60, .instruction = .RTS, .bytes = 1, .cycles = 6, .mode = .Implied, .flags = 0b00000000 },
    Opcode{ .hex = 0x40, .instruction = .RTI, .bytes = 1, .cycles = 6, .mode = .Implied, .flags = 0b00000000 },

    // Branch
    Opcode{ .hex = 0x90, .instruction = .BCC, .bytes = 2, .cycles = 2, .mode = .Relative, .flags = 0b00000000 },
    Opcode{ .hex = 0xB0, .instruction = .BCS, .bytes = 2, .cycles = 2, .mode = .Relative, .flags = 0b00000000 },
    Opcode{ .hex = 0xF0, .instruction = .BEQ, .bytes = 2, .cycles = 2, .mode = .Relative, .flags = 0b00000000 },
    Opcode{ .hex = 0x30, .instruction = .BMI, .bytes = 2, .cycles = 2, .mode = .Relative, .flags = 0b00000000 },
    Opcode{ .hex = 0xD0, .instruction = .BNE, .bytes = 2, .cycles = 2, .mode = .Relative, .flags = 0b00000000 },
    Opcode{ .hex = 0x10, .instruction = .BPL, .bytes = 2, .cycles = 2, .mode = .Relative, .flags = 0b00000000 },
    Opcode{ .hex = 0x50, .instruction = .BVC, .bytes = 2, .cycles = 2, .mode = .Relative, .flags = 0b00000000 },
    Opcode{ .hex = 0x70, .instruction = .BVS, .bytes = 2, .cycles = 2, .mode = .Relative, .flags = 0b00000000 },

    // NoOp
    Opcode{ .hex = 0xEA, .instruction = .NOP, .bytes = 1, .cycles = 2, .mode = .Implied, .flags = 0b00000000 },
};
