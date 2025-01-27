//! file_buffer.zig
//! copyright 2025 @ Joseph R. Pollack

const Allocator = @import("std").mem.Allocator;
const Config = @import("config.zig").Config;

const FileBuffer = struct {
    buffer: []u8,
    num_columns: u32,
    block_size: u32,
    page_size: u32,
    scroll_pos: u32,

    // Takes ownership of the given buffer
    pub fn init(conf: *Config, buffer: []u8) FileBuffer {
        return FileBuffer{ .buffer = buffer, .num_columns = conf.num_columns, .block_size = conf.block_size, .page_size = conf.page_size };
    }

    pub fn deinit(self: *FileBuffer, allocator: Allocator) void {
        allocator.free(self.buffer);
    }

    // You must free the returned buffer!
    pub fn render(self: FileBuffer, allocator: Allocator) ![]u8 {
        // TODO: FileBuffer.render() method
        _ = self;
        _ = allocator;
        return 0;
    }
};
