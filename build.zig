const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "zbar",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const cpu = b.option([]const u8, "cpu_path", "Path to CPU sensor file in /sys/class/thermal/thermal_zone*") orelse "/sys/class/thermal/thermal_zone1/temp";
    const gpu = b.option([]const u8, "gpu_path", "Path to GPU sensor file in /sys/class/hwmon/hwmon*") orelse "/sys/class/hwmon/hwmon2/temp1_input";

    const paths = b.addOptions();
    paths.addOption([]const u8, "cpu_path", cpu);
    paths.addOption([]const u8, "gpu_path", gpu);

    exe.addOptions("paths", paths);

    exe.linkLibC();
    exe.linkSystemLibrary("X11");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
