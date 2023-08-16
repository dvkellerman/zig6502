const std = @import("std");
const CPU = @import("CPU.zig").CPU;
const Memory = @import("Memory.zig").Memory;

pub const NES = struct {
    cpu: *CPU,
    mem: *Memory,

    pub fn create(allocator: *const std.mem.Allocator) !*NES {
        var nes: *NES = try allocator.create(NES);
        nes.cpu = try CPU.create(allocator);
        nes.mem = try Memory.create(allocator);
        return nes;
    }

    pub fn destroy(self: *NES, allocator: *const std.mem.Allocator) void {
        self.cpu.destroy(allocator);
        self.mem.destroy(allocator);
        allocator.destroy(self);
    }

    pub fn load_and_run(self: *NES, rom: []const u8, callback: *const fn () void) !void {
        const offset: u16 = 0x600; // 8000;
        self.load(rom, offset);
        self.mem.write16(0xFFFC, offset);
        self.reset();
        try self.run(callback);
    }

    fn load(self: *NES, rom: []const u8, offset: u16) void {
        var i: u16 = 0;
        while (i < rom.len) : (i += 1) {
            self.mem.write(i + offset, rom[i]);
        }
    }

    fn reset(self: *NES) void {
        self.cpu.reset();
        self.cpu.PC = self.mem.read16(0xFFFC);
    }

    fn run(self: *NES, callback: *const fn () void) !void {
        try self.cpu.run(self.mem, callback);
    }
};
