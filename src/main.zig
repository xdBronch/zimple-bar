const std = @import("std");
const c = @cImport({
    @cInclude("X11/Xlib.h");
});
const f = @import("includes.zig");
const p = @import("paths");

pub fn main() !u8 {
    var buf: [256:0]u8 = undefined;
    var cursor: usize = 0;

    var disp: ?*c.Display = c.XOpenDisplay(0);
    if (disp == null) {
        try std.io.getStdErr().writer().print("Failed to open display\n", .{});
        return 1;
    }

    while (true) {
        cursor += try f.fg(buf[cursor..], "282828");
        cursor += try f.bg(buf[cursor..], "e78a4e");
        cursor += try f.temp(buf[cursor..], p.cpu_path);
        cursor += try f.gap(buf[cursor..]);
        cursor += try f.temp(buf[cursor..], p.gpu_path);
        cursor += try f.gap(buf[cursor..]);
        cursor += try f.bg(buf[cursor..], "a9b665");
        cursor += try f.ram_htoplike(buf[cursor..]);
        cursor += try f.gap(buf[cursor..]);
        cursor += try f.bg(buf[cursor..], "7daea3");
        cursor += try f.time_12(buf[cursor..]);
        cursor += try f.gap(buf[cursor..]);

        if (c.XStoreName(disp, c.DefaultRootWindow(disp), &buf) < 0) {
            try std.io.getStdErr().writer().print("Failed to allocate memory\n", .{});
            return 2;
        } else {
            _ = c.XFlush(disp);
        }
        cursor = 0;
        std.time.sleep(5 * std.time.ns_per_s);
    }

    return 0;
}
