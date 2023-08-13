const std = @import("std");
const Memory = @import("Memory.zig").Memory;
const Opcode = @import("Opcode.zig").Opcode;

pub const AddressingMode = enum { Accumulator, Absolute, AbsoluteX, AbsoluteY, Immediate, Implied, Indirect, IndirectX, IndirectY, Relative, ZeroPage, ZeroPageX, ZeroPageY };

pub const Instruction = enum {
    ADC,
    AND,
    ASL,
    BCC,
    BCS,
    BEQ,
    BIT,
    BMI,
    BNE,
    BPL,
    BRK,
    BVC,
    BVS,
    CLC,
    CLD,
    CLI,
    CLV,
    CMP,
    CPX,
    CPY,
    DEC,
    DEX,
    DEY,
    EOR,
    INC,
    INX,
    INY,
    JMP,
    JSR,
    LDA,
    LDX,
    LDY,
    LSR,
    NOP,
    ORA,
    PHA,
    PHP,
    PLA,
    PLP,
    ROL,
    ROR,
    RTI,
    RTS,
    SBC,
    SEC,
    SED,
    SEI,
    STA,
    STX,
    STY,
    TAX,
    TAY,
    TSX,
    TXA,
    TXS,
    TYA,
};

pub const CPU = struct {
    A: u8,
    X: u8,
    Y: u8,
    SP: u16,
    PC: u16,
    P: u8,

    pub fn create(allocator: *const std.mem.Allocator) !*CPU {
        var cpu: *CPU = try allocator.create(CPU);
        cpu.reset();
        return cpu;
    }

    pub fn destroy(self: *CPU, allocator: *const std.mem.Allocator) void {
        allocator.destroy(self);
    }

    pub fn reset(self: *CPU) void {
        self.A = 0;
        self.X = 0;
        self.Y = 0;
        self.SP = 0x1FF;
        self.PC = 0;
        self.P = 0;
    }

    pub fn run(self: *CPU, mem: *Memory) void {
        while (true) {
            if (self.PC >= 0xFFFF) {
                break;
            }
            var hex = mem.read(self.PC);
            const opcode = Opcode.by_hex(hex);
            // fill this switch with all the instructions
            switch (opcode.instruction) {
                .BRK => {
                    break;
                },
                .ADC => {
                    break;
                },
                .SBC => {
                    break;
                },
                .AND => {
                    break;
                },
                .ORA => {
                    break;
                },
                .EOR => {
                    break;
                },
                .CMP => {
                    break;
                },
                .CPX => {
                    break;
                },
                .CPY => {
                    break;
                },
                .BIT => {
                    break;
                },
                .ASL => {
                    break;
                },
                .LSR => {
                    break;
                },
                .ROL => {
                    break;
                },
                .ROR => {
                    break;
                },
                .INC => {
                    break;
                },
                .INX => {
                    break;
                },
                .INY => {
                    break;
                },
                .DEC => {
                    break;
                },
                .DEX => {
                    break;
                },
                .DEY => {
                    break;
                },
                .JMP => {
                    break;
                },
                .JSR => {
                    break;
                },
                .RTS => {
                    break;
                },
                .BCC => {
                    break;
                },
                .BCS => {
                    break;
                },
                .BEQ => {
                    break;
                },
                .BMI => {
                    break;
                },
                .BNE => {
                    break;
                },
                .BPL => {
                    break;
                },
                .BVC => {
                    break;
                },
                .BVS => {
                    break;
                },
                .CLC => {
                    break;
                },
                .CLD => {
                    break;
                },
                .CLI => {
                    break;
                },
                .CLV => {
                    break;
                },
                .SEC => {
                    break;
                },
                .SED => {
                    break;
                },
                .SEI => {
                    break;
                },
                .LDA => {
                    break;
                },
                .LDX => {
                    break;
                },
                .LDY => {
                    break;
                },
                .STA => {
                    break;
                },
                .STX => {
                    break;
                },
                .STY => {
                    break;
                },
                .TAX => {
                    break;
                },
                .TAY => {
                    break;
                },
                .TSX => {
                    break;
                },
                .TXA => {
                    break;
                },
                .TXS => {
                    break;
                },
                .TYA => {
                    break;
                },
                .PHA => {
                    break;
                },
                .PHP => {
                    break;
                },
                .PLA => {
                    break;
                },
                .PLP => {
                    break;
                },
                .NOP => {
                    break;
                },
                .RTI => {
                    break;
                },
            }
        }
    }
};
