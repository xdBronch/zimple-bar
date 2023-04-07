const std = @import("std");

pub fn temp(buf: [:0]u8, comptime filePath: []const u8) !usize {
    var file = try std.fs.openFileAbsolute(filePath, .{ .mode = .read_only });
    defer file.close();

    var tempbuf: [32]u8 = undefined;
    const size = try file.read(&tempbuf);
    const tempC = try std.fmt.parseInt(usize, tempbuf[0 .. size - 1], 10);

    return (try std.fmt.bufPrintZ(buf, " {d}°C ", .{@divExact(tempC, 1000)})).len;
}
