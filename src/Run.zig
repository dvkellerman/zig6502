const std = @import("std");
const CPU = @import("CPU.zig").CPU;
const Flag = @import("CPU.zig").Flag;
const Memory = @import("Memory.zig").Memory;
const Opcode = @import("Opcode.zig").Opcode;
const Operand = @import("Operand.zig").Operand;

pub fn run(opcode: Opcode, operand: Operand, cpu: *CPU, mem: *Memory) !void {
    switch (opcode.instruction) {
        .BRK => {
            if (!cpu.get_flag(Flag.InterruptDisable)) {
                cpu.set_flag(Flag.Break);
                cpu.push_stack(mem, @truncate(cpu.PC >> 8));
                cpu.push_stack(mem, @truncate(cpu.PC & 0xFF));
                cpu.push_stack(mem, cpu.P);
                cpu.set_flag(Flag.InterruptDisable);
                cpu.PC = mem.read(0xFFFE);
            } else {
                update_P_PC(cpu, null, opcode);
            }
        },
        .ADC => {
            const value = @as(u16, operand.value);
            const carry: u16 = if (cpu.get_flag(Flag.Carry)) 1 else 0;
            const addition: u16 = @as(u16, cpu.A) + value + carry;
            if (addition > 0xFF) {
                cpu.set_flag(Flag.Carry);
            } else {
                cpu.clear_flag(Flag.Carry);
            }
            const result: u8 = @truncate(addition & 0xFF);
            if (((cpu.A ^ value) & 0x80 == 0) and ((cpu.A ^ result) & 0x80 != 0)) {
                cpu.set_flag(Flag.Overflow);
            } else {
                cpu.clear_flag(Flag.Overflow);
            }
            cpu.A = result;
            update_P_PC(cpu, cpu.A, opcode);
        },
        .AND => {
            cpu.A &= operand.value;
            update_P_PC(cpu, cpu.A, opcode);
        },
        .SBC => {
            const value = @as(u16, ~operand.value + 1);
            const carry: u16 = if (cpu.get_flag(Flag.Carry)) 1 else 0;
            const addition: u16 = @as(u16, cpu.A) + value + (1 - carry);
            if (addition > 0xFF) {
                cpu.set_flag(Flag.Carry);
            } else {
                cpu.clear_flag(Flag.Carry);
            }
            const result: u8 = @truncate(addition & 0xFF);
            if (((cpu.A ^ value) & 0x80 == 0) and ((cpu.A ^ result) & 0x80 != 0)) {
                cpu.set_flag(Flag.Overflow);
            } else {
                cpu.clear_flag(Flag.Overflow);
            }
            cpu.A = result;
            update_P_PC(cpu, cpu.A, opcode);
        },
        .ORA => {
            cpu.A |= operand.value;
            update_P_PC(cpu, cpu.A, opcode);
        },
        .EOR => {
            cpu.A ^= operand.value;
            update_P_PC(cpu, cpu.A, opcode);
        },
        .CMP => {
            const value = operand.value;
            if (cpu.A >= value) {
                cpu.set_flag(Flag.Carry);
            } else {
                cpu.clear_flag(Flag.Carry);
            }
            const result: u8 = cpu.A -% value;
            update_P_PC(cpu, result, opcode);
        },
        .CPX => {
            const value = operand.value;
            if (cpu.X >= value) {
                cpu.set_flag(Flag.Carry);
            } else {
                cpu.clear_flag(Flag.Carry);
            }
            const result: u8 = cpu.X -% value;
            update_P_PC(cpu, result, opcode);
        },
        .CPY => {
            const value = operand.value;
            if (cpu.Y >= value) {
                cpu.set_flag(Flag.Carry);
            } else {
                cpu.clear_flag(Flag.Carry);
            }
            const result: u8 = cpu.Y -% value;
            update_P_PC(cpu, result, opcode);
        },
        .BIT => {
            const value = operand.value;
            if (value & 0x80 > 0) {
                cpu.set_flag(Flag.Negative);
            } else {
                cpu.clear_flag(Flag.Negative);
            }
            if (value & 0x40 > 0) {
                cpu.set_flag(Flag.Overflow);
            } else {
                cpu.clear_flag(Flag.Overflow);
            }
            if ((cpu.A & value) == 0) {
                cpu.set_flag(Flag.Zero);
            } else {
                cpu.clear_flag(Flag.Zero);
            }
            update_P_PC(cpu, null, opcode);
        },
        .ASL => {
            const value = if (opcode.mode == .Accumulator) cpu.A else operand.value;
            if (value & 0x80 > 0) {
                cpu.set_flag(Flag.Carry);
            } else {
                cpu.clear_flag(Flag.Carry);
            }
            const result: u8 = @truncate(value << 1);
            if (opcode.mode == .Accumulator) {
                cpu.A = result;
            } else if (operand.address) |address| {
                mem.write(address, result);
            }
            update_P_PC(cpu, result, opcode);
        },
        .LSR => {
            const value = if (opcode.mode == .Accumulator) cpu.A else operand.value;
            if (value & 0x01 > 0) {
                cpu.set_flag(Flag.Carry);
            } else {
                cpu.clear_flag(Flag.Carry);
            }
            const result: u8 = @truncate(value >> 1);
            if (opcode.mode == .Accumulator) {
                cpu.A = result;
            } else if (operand.address) |address| {
                mem.write(address, result);
            }
            update_P_PC(cpu, result, opcode);
        },
        .ROL => {
            const value = if (opcode.mode == .Accumulator) cpu.A else operand.value;
            const carry: u8 = if (cpu.get_flag(Flag.Carry)) 1 else 0;
            if (value & 0x80 > 0) {
                cpu.set_flag(Flag.Carry);
            } else {
                cpu.clear_flag(Flag.Carry);
            }
            const result: u8 = @truncate((value << 1) | carry);
            if (opcode.mode == .Accumulator) {
                cpu.A = result;
            } else if (operand.address) |address| {
                mem.write(address, result);
            }
            update_P_PC(cpu, result, opcode);
        },
        .ROR => {
            const value = if (opcode.mode == .Accumulator) cpu.A else operand.value;
            const carry: u8 = if (cpu.get_flag(Flag.Carry)) 1 else 0;
            if (value & 0x01 > 0) {
                cpu.set_flag(Flag.Carry);
            } else {
                cpu.clear_flag(Flag.Carry);
            }
            const result: u8 = @truncate((value >> 1) | (carry << 7));
            if (opcode.mode == .Accumulator) {
                cpu.A = result;
            } else if (operand.address) |address| {
                mem.write(address, result);
            }
            update_P_PC(cpu, result, opcode);
        },
        .INC => {
            const value = operand.value;
            const result: u8 = value +% 1;
            if (operand.address) |address| {
                mem.write(address, result);
            }
            update_P_PC(cpu, result, opcode);
        },
        .INX => {
            const result: u8 = cpu.X +% 1;
            cpu.X = result;
            update_P_PC(cpu, result, opcode);
        },
        .INY => {
            const result: u8 = cpu.Y +% 1;
            cpu.Y = result;
            update_P_PC(cpu, result, opcode);
        },
        .DEC => {
            const value = operand.value;
            const result: u8 = value -% 1;
            if (operand.address) |address| {
                mem.write(address, result);
            }
            update_P_PC(cpu, result, opcode);
        },
        .DEX => {
            const result: u8 = cpu.X -% 1;
            cpu.X = result;
            update_P_PC(cpu, result, opcode);
        },
        .DEY => {
            const result: u8 = cpu.Y -% 1;
            cpu.Y = result;
            update_P_PC(cpu, result, opcode);
        },
        .JMP => {
            if (operand.address) |unwrapped| {
                cpu.PC = unwrapped;
            }
        },
        .JSR => {
            const PC = cpu.PC + 2;
            cpu.push_stack(mem, @truncate(PC >> 8));
            cpu.push_stack(mem, @truncate(PC & 0xFF));
            if (operand.address) |unwrapped| {
                cpu.PC = unwrapped;
            }
        },
        .RTS => {
            const low: u8 = cpu.pop_stack(mem);
            const high: u8 = cpu.pop_stack(mem);
            cpu.PC = (@as(u16, high) << 8) | @as(u16, low) + 1;
        },
        .BCC => {
            if (!cpu.get_flag(Flag.Carry)) {
                if (operand.address) |offset| {
                    const newPC = cpu.PC + 2 + offset;
                    cpu.PC = newPC;
                }
            } else {
                update_P_PC(cpu, null, opcode);
            }
        },
        .BCS => {
            if (cpu.get_flag(Flag.Carry)) {
                if (operand.address) |offset| {
                    const newPC = cpu.PC + 2 + offset;
                    cpu.PC = newPC;
                }
            } else {
                update_P_PC(cpu, null, opcode);
            }
        },
        .BEQ => {
            if (cpu.get_flag(Flag.Zero)) {
                if (operand.address) |offset| {
                    const newPC = cpu.PC + 2 + offset;
                    cpu.PC = newPC;
                }
            } else {
                update_P_PC(cpu, null, opcode);
            }
        },
        .BMI => {
            if (cpu.get_flag(Flag.Negative)) {
                if (operand.address) |offset| {
                    const newPC = cpu.PC + 2 + offset;
                    cpu.PC = newPC;
                }
            } else {
                update_P_PC(cpu, null, opcode);
            }
        },
        .BNE => {
            if (!cpu.get_flag(Flag.Zero)) {
                if (operand.address) |offset| {
                    const newPC = cpu.PC + 2 + offset;
                    cpu.PC = newPC;
                }
            } else {
                update_P_PC(cpu, null, opcode);
            }
        },
        .BPL => {
            if (!cpu.get_flag(Flag.Negative)) {
                if (operand.address) |offset| {
                    const newPC = cpu.PC + 2 + offset;
                    cpu.PC = newPC;
                }
            } else {
                update_P_PC(cpu, null, opcode);
            }
        },
        .BVC => {
            if (!cpu.get_flag(Flag.Overflow)) {
                if (operand.address) |offset| {
                    const newPC = cpu.PC + 2 + offset;
                    cpu.PC = newPC;
                }
            } else {
                update_P_PC(cpu, null, opcode);
            }
        },
        .BVS => {
            if (cpu.get_flag(Flag.Overflow)) {
                if (operand.address) |offset| {
                    const newPC = cpu.PC + 2 + offset;
                    cpu.PC = newPC;
                }
            } else {
                update_P_PC(cpu, null, opcode);
            }
        },
        .CLC => {
            cpu.clear_flag(Flag.Carry);
            update_P_PC(cpu, null, opcode);
        },
        .CLD => {
            cpu.clear_flag(Flag.DecimalMode);
            update_P_PC(cpu, null, opcode);
        },
        .CLI => {
            cpu.clear_flag(Flag.InterruptDisable);
            update_P_PC(cpu, null, opcode);
        },
        .CLV => {
            cpu.clear_flag(Flag.Overflow);
            update_P_PC(cpu, null, opcode);
        },
        .SEC => {
            cpu.set_flag(Flag.Carry);
            update_P_PC(cpu, null, opcode);
        },
        .SED => {
            cpu.set_flag(Flag.DecimalMode);
            update_P_PC(cpu, null, opcode);
        },
        .SEI => {
            cpu.set_flag(Flag.InterruptDisable);
            update_P_PC(cpu, null, opcode);
        },
        .LDA => {
            cpu.A = operand.value;
            update_P_PC(cpu, cpu.A, opcode);
        },
        .LDX => {
            cpu.X = operand.value;
            update_P_PC(cpu, cpu.X, opcode);
        },
        .LDY => {
            cpu.Y = operand.value;
            update_P_PC(cpu, cpu.Y, opcode);
        },
        .STA => {
            if (operand.address) |address| {
                mem.write(address, cpu.A);
            }
            update_P_PC(cpu, null, opcode);
        },
        .STX => {
            if (operand.address) |address| {
                mem.write(address, cpu.X);
            }
            update_P_PC(cpu, null, opcode);
        },
        .STY => {
            if (operand.address) |address| {
                mem.write(address, cpu.Y);
            }
            update_P_PC(cpu, null, opcode);
        },
        .TAX => {
            cpu.X = cpu.A;
            update_P_PC(cpu, cpu.X, opcode);
        },
        .TAY => {
            cpu.Y = cpu.A;
            update_P_PC(cpu, cpu.Y, opcode);
        },
        .TSX => {
            cpu.X = cpu.pop_stack(mem);
            update_P_PC(cpu, cpu.X, opcode);
        },
        .TXA => {
            cpu.A = cpu.X;
            update_P_PC(cpu, cpu.A, opcode);
        },
        .TXS => {
            cpu.push_stack(mem, cpu.X);
            update_P_PC(cpu, null, opcode);
        },
        .TYA => {
            cpu.A = cpu.Y;
            update_P_PC(cpu, cpu.A, opcode);
        },
        .PHA => {
            cpu.push_stack(mem, cpu.A);
            update_P_PC(cpu, null, opcode);
        },
        .PHP => {
            cpu.push_stack(mem, cpu.P);
            update_P_PC(cpu, null, opcode);
        },
        .PLA => {
            cpu.A = cpu.pop_stack(mem);
            update_P_PC(cpu, cpu.A, opcode);
        },
        .PLP => {
            cpu.P = cpu.pop_stack(mem);
            update_P_PC(cpu, null, opcode);
        },
        .NOP => {
            update_P_PC(cpu, null, opcode);
        },
        .RTI => {
            cpu.P = cpu.pop_stack(mem);
            cpu.PC = @as(u16, cpu.pop_stack(mem));
            cpu.PC |= @as(u16, cpu.pop_stack(mem)) << 8;
            update_P_PC(cpu, null, opcode);
        },
    }
}

fn update_P_PC(self: *CPU, value: ?u8, opcode: Opcode) void {
    if (value) |unwraped| {
        if (unwraped == 0) {
            self.set_flag(Flag.Zero);
        } else {
            self.clear_flag(Flag.Zero);
        }
        if (unwraped & 0x80 > 0) {
            self.set_flag(Flag.Negative);
        } else {
            self.clear_flag(Flag.Negative);
        }
    }
    self.PC += opcode.bytes;
}
