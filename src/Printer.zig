const std = @import("std");
const CPU = @import("cpu").CPU;
const Memory = @import("memory").Memory;
const Opcode = @import("opcode").Opcode;

pub fn print(cpu: CPU, mem: Memory, opcode: Opcode) !void {
    const PC = cpu.PC;
    const hex: u8 = opcode.hex;
    const instruction: []const u8 = @tagName(opcode.instruction);

    const operand: Operand = Operand.get(cpu, mem, opcode);

    const stdout = std.io.getStdOut().writer();
    if (operand.value == null) {
        try stdout.print("0x{:04x}    {:02x}        {} {}\n", .{ PC, hex, instruction });
    } else if (operand.value) |value| {
        const hi = (value >> 8);
        const lo = (value & 0xFF);
        if (hi != 0) {
            try stdout.print("0x{:04x}    {:02x} {:02x} {:02x}  {s} {s}\n", .{ PC, hex, lo, hi, instruction, operand.formatted });
        } else {
            try stdout.print("0x{:04x}    {:02x} {:02x}     {s} {s}\n", .{ PC, hex, lo, instruction, operand.formatted });
        }
    }
}

const Operand = struct {
    value: ?u16,
    formatted: ?[]const u8,

    fn get(cpu: CPU, mem: Memory, opcode: Opcode) Operand {
        return switch (opcode.mode) {
            .Accumulator => {
                return Operand{ .value = null, .formatted = "A" };
            },
            .Absolute => {
                const addr = mem.read16(cpu.PC + 1);
                return Operand{ .value = addr, .formatted = "${:04x}".format(.{ lo, hi }) };
            },
            .AbsoluteX => {
                const addr = mem.read16(cpu.PC + 1);
                return Operand{ .value = addr, .formatted = "${:04x},X".format(.{addr}) };
            },
            .AbsoluteY => {
                const addr = mem.read16(cpu.PC + 1);
                return Operand{ .value = addr, .formatted = "${:04x},Y".format(.{addr}) };
            },
            .Relative => {
                const newPC = mem.read(cpu.PC + 1) + 2 + cpu.PC;
                return Operand{ .value = newPC, .formatted = "${:04x}".format(.{newPC}) };
            },
            .Indirect => {
                const addr = mem.read16(cpu.PC + 1);
                return Operand{ .value = addr, .formatted = "(${:04x})".format(.{addr}) };
            },
            .IndirectX => {
                const addr = mem.read(cpu.PC + 1);
                return Operand{ .value = addr, .formatted = "(${:02x},X)".format(.{addr}) };
            },
            .IndirectY => {
                const addr = mem.read(cpu.PC + 1);
                return Operand{ .value = addr, .formatted = "(${:02x}),Y".format(.{addr}) };
            },
            .Implied => {
                return Operand{ .value = null, .formatted = null };
            },
            .Immediate => {
                const value = mem.read(cpu.PC + 1);
                return Operand{ .value = value, .formatted = "#${:02x}".format(.{value}) };
            },
            .ZeroPage => {
                const addr = mem.read(cpu.PC + 1);
                return Operand{ .value = addr, .formatted = "${:02x}".format(.{addr}) };
            },
            .ZeroPageX => {
                const addr = mem.read(cpu.PC + 1);
                return Operand{ .value = addr, .formatted = "${:02x},X".format(.{addr}) };
            },
            .ZeroPageY => {
                const addr = mem.read(cpu.PC + 1);
                return Operand{ .value = addr, .formatted = "${:02x},Y".format(.{addr}) };
            },
        };
    }
};
