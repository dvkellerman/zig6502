const std = @import("std");
const cpuModule = @import("CPU.zig");
const CPU = cpuModule.CPU;
const AddressingMode = cpuModule.AddressingMode;
const Opcode = @import("Opcode.zig").Opcode;
const Memory = @import("Memory.zig").Memory;

pub const Operand = struct {
    address: ?u16,
    value: u8,

    fn get_operand_address(cpu: *CPU, mem: *Memory, mode: AddressingMode) ?u16 {
        var address: u16 = 0;

        switch (mode) {
            .Immediate, .Relative => {
                address = @as(u16, mem.read(cpu.PC + 1));
            },
            .Absolute => {
                address = mem.read16(cpu.PC + 1);
            },
            .AbsoluteX => {
                const base = mem.read16(cpu.PC + 1);
                address = base +% @as(u16, cpu.X);
            },
            .AbsoluteY => {
                const base = mem.read16(cpu.PC + 1);
                address = base +% @as(u16, cpu.Y);
            },
            .ZeroPage => {
                address = @as(u16, mem.read(cpu.PC + 1));
            },
            .ZeroPageX => {
                const base = mem.read(cpu.PC + 1);
                address = @as(u16, base +% cpu.X);
            },
            .ZeroPageY => {
                const base = mem.read(cpu.PC + 1);
                address = @as(u16, base +% cpu.Y);
            },
            .Indirect => {
                const base = mem.read16(cpu.PC + 1);
                const lo = mem.read(base);
                const hi = mem.read(base + 1);
                address = @as(u16, hi) << 8 | @as(u16, lo);
            },
            .IndirectX => {
                const base = mem.read(cpu.PC + 1);
                const ptr = base +% cpu.X;
                const lo = mem.read(@as(u16, ptr));
                const hi = mem.read(@as(u16, ptr + 1));
                address = @as(u16, hi) << 8 | @as(u16, lo);
            },
            .IndirectY => {
                const ptr = mem.read(cpu.PC + 1);
                const lo = mem.read(@as(u16, ptr));
                const hi = mem.read(@as(u16, ptr + 1));
                address = @as(u16, hi) << 8 | @as(u16, lo);
                address +%= @as(u16, cpu.Y);
            },
            .Implied, .Accumulator => {
                return null;
            },
        }

        return address;
    }

    pub fn get_operand(cpu: *CPU, mem: *Memory, opcode: Opcode) Operand {
        var operand: Operand = .{
            .address = null,
            .value = 0,
        };

        const address = get_operand_address(cpu, mem, opcode.mode);

        return switch (opcode.mode) {
            .Implied, .Accumulator => {
                return operand;
            },
            .Immediate => {
                if (address) |addr| {
                    operand.value = @truncate(addr);
                }
                return operand;
            },
            .Relative => {
                if (address) |addr| {
                    operand.address = addr;
                }
                return operand;
            },
            else => {
                if (address) |addr| {
                    operand.value = mem.read(addr);
                }
                operand.address = address;
                return operand;
            },
        };
    }
};
