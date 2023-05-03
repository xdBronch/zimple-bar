const std = @import("std");
const c = @cImport(@cInclude("time.h"));

pub fn time_24(buf: []u8) !usize {
    var now: c.time_t = c.time(0);
    var now_tm: *c.tm = c.localtime(&now);

    return (try std.fmt.bufPrintZ(buf, " {d:0>2}:{d:0>2} ", .{
        @intCast(c_uint, now_tm.tm_hour),
        @intCast(c_uint, now_tm.tm_min),
    })).len;
}

pub fn time_12(buf: []u8) !usize {
    var now: c.time_t = c.time(0);
    var now_tm: *c.tm = c.localtime(&now);

    var hour = @intCast(c_uint, now_tm.*.tm_hour);
    var half: [2]u8 = undefined;
    if (hour > 12) {
        std.mem.copy(u8, half[0..], "PM");
        hour -= 12;
    } else {
        std.mem.copy(u8, half[0..], "AM");
        if (hour == 0) hour = 12;
    }

    return (try std.fmt.bufPrintZ(buf, " {d}/{d} {d:0>2}:{d:0>2} {s} ", .{
        @intCast(c_uint, now_tm.tm_mon),
        @intCast(c_uint, now_tm.tm_mday),
        @intCast(c_uint, hour),
        @intCast(c_uint, now_tm.tm_min),
        half,
    })).len;
}
