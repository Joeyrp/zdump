//! file_buffer.zig
//! copyright 2025 @ Joseph R. Pollack
const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Config = @import("config.zig").Config;

pub const BufferRenderer = struct {
    buffer: []u8,
    num_columns: u32,
    block_size: u32,
    page_size: u32,
    scroll_pos: u32 = 0,

    // Takes ownership of the given buffer
    pub fn init(conf: *const Config, buffer: []u8) BufferRenderer {
        return BufferRenderer{ .buffer = buffer, .num_columns = conf.num_columns, .block_size = conf.block_size, .page_size = conf.page_size };
    }

    pub fn deinit(self: *BufferRenderer, allocator: Allocator) void {
        allocator.free(self.buffer);
    }

    // You must free the returned buffer!
    pub fn render(self: BufferRenderer, allocator: Allocator) ![]u8 {
        var final_buf = ArrayList(u8).init(allocator);
        defer final_buf.deinit();

        var decode_buf = ArrayList(u8).init(allocator);
        defer decode_buf.deinit();

        var offset: u32 = 0;
        var columns: u32 = 0;
        var blocks: u32 = 0;

        // Render Header
        try final_buf.appendSlice("         ");
        var ti: u32 = 0;
        while (ti < self.num_columns) : (ti += self.block_size) {
            const tbuf = try std.fmt.allocPrint(allocator, "{X:02}", .{ti});
            defer allocator.free(tbuf);
            try final_buf.appendSlice(tbuf);

            var tj: u32 = 0;
            while (tj < self.block_size * 2 - 1) : (tj += 1) {
                try final_buf.append(' ');
            }
        }

        try final_buf.appendSlice(" ascii decoded:\n");

        // Render Bytes
        try final_buf.appendSlice("00000000 ");
        for (self.buffer) |byte| {
            const temp_buf = try std.fmt.allocPrint(allocator, "{X:02}", .{byte});
            defer allocator.free(temp_buf);
            try final_buf.appendSlice(temp_buf);

            const print_char = if (is_printable(byte)) byte else '.';

            const dc_temp_buf = try std.fmt.allocPrint(allocator, "{c}", .{print_char});
            defer allocator.free(dc_temp_buf);
            try decode_buf.appendSlice(dc_temp_buf);

            offset += 1;
            blocks += 1;
            if (blocks >= self.block_size) {
                try final_buf.append(' ');
                blocks = 0;
            }

            columns += 1;
            if (columns >= self.num_columns) {
                // TODO: Render the decoded bytes in a new column after a space or tab
                try final_buf.appendSlice(" ");
                const copy_buf = try allocator.alloc(u8, decode_buf.items.len);
                defer allocator.free(copy_buf);
                @memcpy(copy_buf, decode_buf.items);
                try final_buf.appendSlice(copy_buf);
                try final_buf.appendSlice("\n");
                const tbuf = try std.fmt.allocPrint(allocator, "{X:08} ", .{offset});
                defer allocator.free(tbuf);
                try final_buf.appendSlice(tbuf);
                columns = 0;
                decode_buf.clearAndFree();
            }
        }

        const return_buf = try allocator.alloc(u8, final_buf.items.len);
        std.mem.copyForwards(u8, return_buf, final_buf.items);

        return return_buf;
    }
};

fn is_printable(byte: u8) bool {
    return (byte > 31 and byte < 127);
}
