const std = @import("std");
const Memory = @import("Memory.zig").Memory;
const Opcode = @import("Opcode.zig").Opcode;
const Operand = @import("Operand.zig").Operand;
const Debug = @import("Debug.zig");
const Run = @import("Run.zig");

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

pub const Flag = enum(u8) {
    Carry = 1 << 0,
    Zero = 1 << 1,
    InterruptDisable = 1 << 2,
    DecimalMode = 1 << 3,
    Break = 1 << 4,
    Break2 = 1 << 5,
    Overflow = 1 << 6,
    Negative = 1 << 7,
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
        self.SP = 0xFF;
        self.PC = 0;
        self.P = 0;
    }

    pub fn get_flag(self: *CPU, flag: Flag) bool {
        return (self.P & @intFromEnum(flag)) != 0;
    }

    pub fn set_flag(self: *CPU, flag: Flag) void {
        self.P |= @intFromEnum(flag);
    }

    pub fn clear_flag(self: *CPU, flag: Flag) void {
        self.P &= ~@intFromEnum(flag);
    }

    pub fn push_stack(self: *CPU, mem: *Memory, value: u8) void {
        mem.write(0x100 | self.SP, value);
        self.SP -= 1;
    }

    pub fn pop_stack(self: *CPU, mem: *Memory) u8 {
        self.SP += 1;
        return mem.read(0x100 | self.SP);
    }

    pub fn run(self: *CPU, mem: *Memory, callback: *const fn () void) !void {
        while (true) {
            var hex = mem.read(self.PC);
            const op = Opcode.by_hex(hex);
            try Debug.print(self, mem, op);
            const operand = Operand.get_operand(self, mem, op);
            try Run.run(op, operand, self, mem);
            callback();
        }
    }
};
