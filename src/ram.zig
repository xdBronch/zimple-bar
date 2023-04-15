const std = @import("std");
const c = @cImport(@cInclude("sys/sysinfo.h"));
const index = @import("std").mem.indexOfAny;

pub fn ram(buf: [:0]u8) !usize {
    var si: c.struct_sysinfo = undefined;

    var total: f32 = 0;
    var used: f32 = 0;

    if (c.sysinfo(&si) != 0) {
        return (try std.fmt.bufPrintZ(buf[0..], " FAILED TO READ RAM ", .{})).len;
    }

    total = @intToFloat(f32, si.totalram / (1024 * 1024 * 1024));
    used = @intToFloat(f32, (si.totalram - si.freeram - si.bufferram - si.sharedram) / (1024 * 1024));

    if (used < 1000) {
        return (try std.fmt.bufPrintZ(buf[0..], " {d:.1}M/{d:.1}G ", .{ used, total })).len;
    }

    used /= 1024;
    return (try std.fmt.bufPrintZ(buf[0..], " {d:.1}G/{d:.1}G ", .{ used, total })).len;
}

pub fn ram_htoplike(buf: [:0]u8) !usize {
    var file = try std.fs.openFileAbsolute("/proc/meminfo", .{ .mode = .read_only });
    defer file.close();

    var total: f32 = 0;
    var free: f32 = 0;
    var used: f32 = 0;
    var buffered: f32 = 0;
    var cached: f32 = 0;

    var lineBuf: [32:0]u8 = undefined;
    _ = try file.reader().readUntilDelimiter(&lineBuf, '\n');
    total = @intToFloat(f32, atoi(lineBuf[indexOfPosRange(u8, &lineBuf, 0, '1', '9').?..]));

    _ = try file.reader().readUntilDelimiter(&lineBuf, '\n');
    free = @intToFloat(f32, atoi(lineBuf[indexOfPosRange(u8, &lineBuf, 0, '1', '9').?..]));

    _ = try file.reader().readUntilDelimiter(&lineBuf, '\n');

    _ = try file.reader().readUntilDelimiter(&lineBuf, '\n');
    buffered = @intToFloat(f32, atoi(lineBuf[indexOfPosRange(u8, &lineBuf, 0, '1', '9').?..]));

    _ = try file.reader().readUntilDelimiter(&lineBuf, '\n');
    cached = @intToFloat(f32, atoi(lineBuf[indexOfPosRange(u8, &lineBuf, 0, '1', '9').?..]));

    used = total - free - buffered - cached;
    used /= 1024;
    total /= 1024 * 1024;

    if (used < 1000) {
        return (try std.fmt.bufPrintZ(buf, " {d:.1}M/{d:.1}G ", .{ used, total })).len;
    }

    return (try std.fmt.bufPrintZ(buf, " {d:.1}G/{d:.1}G ", .{ used / 1024, total })).len;
}

fn atoi(buf: []u8) usize {
    var ret: i32 = 0;
    for (0..buf.len) |i| {
        if (!(buf[i] >= '0' and buf[i] <= '9')) {
            break;
        }
        ret *= 10;
        ret += buf[i] - '0';
    }
    return @intCast(usize, ret);
}

fn indexOfPosRange(comptime T: type, slice: []const T, start_index: usize, min: T, max: T) ?usize {
    var i: usize = start_index;
    while (i < slice.len) : (i += 1) {
        if (slice[i] >= min and slice[i] <= max) return i;
    }
    return null;
}
