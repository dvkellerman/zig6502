const std = @import("std");
const CPU = @import("CPU.zig").CPU;
const Flag = @import("CPU.zig").Flag;
const Memory = @import("Memory.zig").Memory;
const Opcode = @import("Operand.zig").Operand;
const Operand = @import("Operand.zig").Operand;

pub fn run(opcode: Opcode, operand: Operand, cpu: *CPU, mem: *Memory) !void {
    _ = mem;
    _ = cpu;
    _ = operand;

    switch (opcode.instruction) {
        .BRK => {},
        .ADC => {},
        .AND => {},
        .SBC => {},
        .ORA => {},
        .EOR => {},
        .CMP => {},
        .CPX => {},
        .CPY => {},
        .BIT => {},
        .ASL => {},
        .LSR => {},
        .ROL => {},
        .ROR => {},
        .INC => {},
        .INX => {},
        .INY => {},
        .DEC => {},
        .DEX => {},
        .DEY => {},
        .JMP => {},
        .JSR => {},
        .RTS => {},
        .BCC => {},
        .BCS => {},
        .BEQ => {},
        .BMI => {},
        .BNE => {},
        .BPL => {},
        .BVC => {},
        .BVS => {},
        .CLC => {},
        .CLD => {},
        .CLI => {},
        .CLV => {},
        .SEC => {},
        .SED => {},
        .SEI => {},
        .LDA => {},
        .LDX => {},
        .LDY => {},
        .STA => {},
        .STX => {},
        .STY => {},
        .TAX => {},
        .TAY => {},
        .TSX => {},
        .TXA => {},
        .TXS => {},
        .TYA => {},
        .PHA => {},
        .PHP => {},
        .PLA => {},
        .PLP => {},
        .NOP => {},
        .RTI => {},
    }
}

fn update_P_PC(self: *CPU, value: u8, opcode: Opcode) void {
    if (value == 0) {
        self.set_flag(Flag.Zero);
    } else {
        self.clear_flag(Flag.Zero);
    }
    if (value & 0x80) {
        self.set_flag(Flag.Negative);
    } else {
        self.clear_flag(Flag.Negative);
    }
    self.PC += opcode.bytes - 1;
}
