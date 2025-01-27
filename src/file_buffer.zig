//! file_buffer.zig
//! copyright 2025 @ Joseph R. Pollack
const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Config = @import("config.zig").Config;

pub const FileBuffer = struct {
    buffer: []u8,
    num_columns: u32,
    block_size: u32,
    page_size: u32,
    scroll_pos: u32 = 0,

    // Takes ownership of the given buffer
    pub fn init(conf: *const Config, buffer: []u8) FileBuffer {
        return FileBuffer{ .buffer = buffer, .num_columns = conf.num_columns, .block_size = conf.block_size, .page_size = conf.page_size };
    }

    pub fn deinit(self: *FileBuffer, allocator: Allocator) void {
        allocator.free(self.buffer);
    }

    // You must free the returned buffer!
    pub fn render(self: FileBuffer, allocator: Allocator) ![]u8 {
        var final_buf = ArrayList(u8).init(allocator);
        defer final_buf.deinit();

        // wrt block size: 1 column is a full block. so when
        // block_size == 1, 1 column == 1 byte, but when
        // block_size == 2, 1 column == 2 bytes
        var columns: u32 = 0;
        var blocks: u32 = 0;
        for (self.buffer) |byte| {
            const temp_buf = try std.fmt.allocPrint(allocator, "{X:02}", .{byte});
            defer allocator.free(temp_buf);
            try final_buf.appendSlice(temp_buf);

            blocks += 1;
            if (blocks >= self.block_size) {
                try final_buf.append(' ');
                blocks = 0;
            }

            columns += 1;
            if (columns >= self.num_columns) {
                try final_buf.appendSlice("\n");
                columns = 0;
            }
        }

        const return_buf = try allocator.alloc(u8, final_buf.items.len);
        std.mem.copyForwards(u8, return_buf, final_buf.items);

        return return_buf;
    }
};
