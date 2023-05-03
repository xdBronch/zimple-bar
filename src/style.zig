const std = @import("std");

pub fn fg(buf: []u8, comptime color: []const u8) !usize {
    return (try std.fmt.bufPrintZ(buf, "^c#{s}^", .{color})).len;
}

pub fn bg(buf: []u8, comptime color: []const u8) !usize {
    return (try std.fmt.bufPrintZ(buf, "^b#{s}^", .{color})).len;
}

const gap_str = "^f10^\x00";

pub fn gap(buf: []u8) !usize {
    std.mem.copy(u8, buf, gap_str);
    return 5;
}
