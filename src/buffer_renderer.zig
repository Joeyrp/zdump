//! file_buffer.zig
//! copyright 2025 @ Joseph R. Pollack
const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const Config = @import("config.zig").Config;

pub const BufferRenderer = struct {
    buffer: []u8,
    num_columns: u32,
    offset: u32 = 0,
    block_size: u32,
    page_size: u32 = 10, // Number of rows basically

    // Takes ownership of the given buffer
    pub fn init(conf: *const Config, buffer: []u8) BufferRenderer {
        return BufferRenderer{ .buffer = buffer, .num_columns = conf.num_columns, .offset = conf.offset, .block_size = conf.block_size, .page_size = conf.page_size };
    }

    pub fn deinit(self: *BufferRenderer, allocator: Allocator) void {
        allocator.free(self.buffer);
    }

    // You must free the returned buffer!
    pub fn render(self: *BufferRenderer, allocator: Allocator) ![]u8 {
        var final_buf = ArrayList(u8).init(allocator);
        defer final_buf.deinit();

        var decode_buf = ArrayList(u8).init(allocator);
        defer decode_buf.deinit();

        var rows: u32 = 0;
        var columns: u32 = 0;
        var blocks: u32 = 0;
        var bytes_left_in_block: u32 = self.block_size;

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
        const fmt_buf = try std.fmt.allocPrint(allocator, "{X:08} ", .{self.offset});
        defer allocator.free(fmt_buf);
        try final_buf.appendSlice(fmt_buf);
        for (self.buffer[self.offset..]) |byte| {
            const temp_buf = try std.fmt.allocPrint(allocator, "{X:02}", .{byte});
            defer allocator.free(temp_buf);
            try final_buf.appendSlice(temp_buf);

            const print_char = if (is_printable(byte)) byte else '.';

            const dc_temp_buf = try std.fmt.allocPrint(allocator, "{c}", .{print_char});
            defer allocator.free(dc_temp_buf);
            try decode_buf.appendSlice(dc_temp_buf);

            self.offset += 1;
            blocks += 1;
            bytes_left_in_block -= 1;
            if (blocks >= self.block_size) {
                try final_buf.append(' ');
                blocks = 0;
                bytes_left_in_block = self.block_size;
            }

            columns += 1;
            if (columns >= self.num_columns) {
                // Render Decode Column
                try final_buf.appendSlice(" ");
                const copy_buf = try allocator.alloc(u8, decode_buf.items.len);
                defer allocator.free(copy_buf);
                @memcpy(copy_buf, decode_buf.items);
                try final_buf.appendSlice(copy_buf);
                try final_buf.appendSlice("\n");
                const tbuf = try std.fmt.allocPrint(allocator, "{X:08} ", .{self.offset});
                defer allocator.free(tbuf);
                try final_buf.appendSlice(tbuf);
                columns = 0;
                rows += 1;
                decode_buf.clearAndFree();
            }

            if (rows >= self.page_size) {
                break;
            }
        }

        // If there's an incomplete block we need to add an extra space for it
        var partial_block_space: u32 = 1;
        if (self.block_size == bytes_left_in_block) {
            bytes_left_in_block = 0;
            partial_block_space = 0;
        }

        // Render final decode section
        const cols_remaining = self.num_columns - columns;
        const blocks_remaining = cols_remaining / self.block_size;
        const spaces_per_block = self.block_size * 2 + 1;
        const spaces_remaining = blocks_remaining * spaces_per_block + 1 + bytes_left_in_block * 2 + partial_block_space;

        // std.debug.print("COLUMNS REMAINING: {d}, BLOCKS REMAINING: {d}, SPACES PER BLOCK: {d}, BYTES LEFT IN LAST BLOCK: {d}, SPACES REMAINING: {d}\n", .{ cols_remaining, blocks_remaining, spaces_per_block, bytes_left_in_block, spaces_remaining });

        var i: u32 = 0;
        while (i < spaces_remaining) : (i += 1) {
            try final_buf.appendSlice(" ");
        }
        const copy_buf = try allocator.alloc(u8, decode_buf.items.len);
        defer allocator.free(copy_buf);
        @memcpy(copy_buf, decode_buf.items);
        try final_buf.appendSlice(copy_buf);
        try final_buf.appendSlice("\n");

        const return_buf = try allocator.alloc(u8, final_buf.items.len);
        std.mem.copyForwards(u8, return_buf, final_buf.items);

        return return_buf;
    }
};

fn is_printable(byte: u8) bool {
    return (byte > 31 and byte < 127);
}
