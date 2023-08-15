const std = @import("std");
const fmt = std.fmt;
const CPU = @import("CPU.zig").CPU;
const Memory = @import("Memory.zig").Memory;
const Opcode = @import("Opcode.zig").Opcode;

pub fn print(cpu: *CPU, mem: *Memory, opcode: Opcode) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();
    defer {
        _ = gpa.deinit();
    }
    const PC = cpu.PC;
    const hex: u8 = opcode.hex;
    const instruction: []const u8 = @tagName(opcode.instruction);

    const operand: Operand = try Operand.get(cpu, mem, opcode, allocator);

    const stdout = std.io.getStdOut().writer();
    if (operand.value == null) {
        try stdout.print("0x{x:0>4}    {x:0>2}        {s}\n", .{ PC, hex, instruction });
    } else if (operand.value) |value| {
        const hi = (value >> 8);
        const lo = (value & 0xFF);
        if (hi != 0) {
            if (operand.formatted) |formatted| {
                try stdout.print("0x{x:0>4}    {x:0>2} {x:0>2} {x:0>2}  {s} {s}\n", .{ PC, hex, lo, hi, instruction, formatted });
            }
        } else {
            if (operand.formatted) |formatted| {
                try stdout.print("0x{x:0>4}    {x:0>2} {x:0>2}     {s} {s}\n", .{ PC, hex, lo, instruction, formatted });
            }
        }
    }
    if (operand.formatted) |formatted| {
        allocator.free(formatted);
    }
}

const Operand = struct {
    value: ?u16,
    formatted: ?[]const u8,

    fn get(cpu: *CPU, mem: *Memory, opcode: Opcode, allocator: std.mem.Allocator) !Operand {
        return switch (opcode.mode) {
            .Accumulator => {
                const formatted = try fmt.allocPrint(allocator, "A", .{});
                return Operand{ .value = null, .formatted = formatted };
            },
            .Absolute => {
                const addr = mem.read16(cpu.PC + 1);
                const formatted = try fmt.allocPrint(allocator, "${x:0>4}", .{addr});
                return Operand{ .value = addr, .formatted = formatted };
            },
            .AbsoluteX => {
                const addr = mem.read16(cpu.PC + 1);
                const formatted = try fmt.allocPrint(allocator, "${x:0>4},X", .{addr});
                return Operand{ .value = addr, .formatted = formatted };
            },
            .AbsoluteY => {
                const addr = mem.read16(cpu.PC + 1);
                const formatted = try fmt.allocPrint(allocator, "${x:0>4},Y", .{addr});
                return Operand{ .value = addr, .formatted = formatted };
            },
            .Relative => {
                const offset = mem.read(cpu.PC + 1);
                const newPC = cpu.PC + 2 + offset;
                const formatted = try fmt.allocPrint(allocator, "${x:0>4}", .{newPC});
                return Operand{ .value = newPC, .formatted = formatted };
            },
            .Indirect => {
                const addr = mem.read16(cpu.PC + 1);
                const formatted = try fmt.allocPrint(allocator, "(${x:0>4})", .{addr});
                return Operand{ .value = addr, .formatted = formatted };
            },
            .IndirectX => {
                const addr = mem.read(cpu.PC + 1);
                const formatted = try fmt.allocPrint(allocator, "(${x:0>2},X)", .{addr});
                return Operand{ .value = addr, .formatted = formatted };
            },
            .IndirectY => {
                const addr = mem.read(cpu.PC + 1);
                const formatted = try fmt.allocPrint(allocator, "(${x:0>2}),Y", .{addr});
                return Operand{ .value = addr, .formatted = formatted };
            },
            .Implied => {
                return Operand{ .value = null, .formatted = null };
            },
            .Immediate => {
                const value = mem.read(cpu.PC + 1);
                const formatted = try fmt.allocPrint(allocator, "#${x:0>2}", .{value});
                return Operand{ .value = value, .formatted = formatted };
            },
            .ZeroPage => {
                const addr = mem.read(cpu.PC + 1);
                const formatted = try fmt.allocPrint(allocator, "${x:0>2}", .{addr});
                return Operand{ .value = addr, .formatted = formatted };
            },
            .ZeroPageX => {
                const addr = mem.read(cpu.PC + 1);
                const formatted = try fmt.allocPrint(allocator, "${x:0>2},X", .{addr});
                return Operand{ .value = addr, .formatted = formatted };
            },
            .ZeroPageY => {
                const addr = mem.read(cpu.PC + 1);
                const formatted = try fmt.allocPrint(allocator, "${x:0>2},Y", .{addr});
                return Operand{ .value = addr, .formatted = formatted };
            },
        };
    }
};
