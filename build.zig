const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{ .name = "zig6502", .root_source_file = .{ .path = "src/main.zig" }, .optimize = optimize, .target = target });
    exe.linkSystemLibrary("sdl2");
    exe.linkSystemLibrary("C");
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const exe_tests = b.addTest(.{ .root_source_file = .{ .path = "src/main.zig" }, .optimize = optimize, .target = target });
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
