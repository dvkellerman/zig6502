const std = @import("std");

pub const Memory = struct {
    data: [0xFFFF]u8,

    pub fn create(allocator: *const std.mem.Allocator) !*Memory {
        var memory: *Memory = try allocator.create(Memory);
        memory.data = [_]u8{0} ** 0xFFFF;
        return memory;
    }

    pub fn destroy(self: *Memory, allocator: *const std.mem.Allocator) void {
        allocator.destroy(self);
    }

    pub fn reset(self: *Memory) void {
        self.data = [_]u8{0} ** 0xFFFF;
    }

    pub fn read(self: Memory, address: u16) u8 {
        return self.data[address];
    }

    pub fn write(self: *Memory, address: u16, value: u8) void {
        self.data[address] = value;
    }

    pub fn dump(self: Memory) !void {
        var i: u16 = 0;
        while (i < 0xFFFF) : (i += 1) {
            try std.io.getStdOut().writter().print("0x{x}\n", .{self.data[i]});
        }
    }

    pub fn write16(self: *Memory, address: u16, value: u16) void {
        self.data[address] = @truncate(value & 0xFF);
        self.data[address + 1] = @truncate(value >> 8);
    }

    pub fn read16(self: Memory, address: u16) u16 {
        return @as(u16, self.data[address] | (@as(u16, self.data[address + 1]) << 8));
    }
};
