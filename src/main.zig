//! File:   main.zig
//! Author: Joseph R Pollack
//! Copyright 2025
//!
//! dumps the binary data from a given file

// TODO: Use NotCurses to make an interactive ui

const std = @import("std");
const config = @import("config.zig");

pub fn main() !u8 {
    const stdout = std.io.getStdOut().writer();

    // Get allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Parse args into string array
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try stdout.print("Error: Expected filename\n", .{});
        return 1;
    }

    const conf = try config.Config.init(args);

    // if (std.mem.eql(u8, args[1], "--dump-test")) {
    if (conf.dump_test_file) {
        const file = try std.fs.cwd().createFile("test_file", .{ .read = true });
        defer file.close();

        var i: u32 = 0;
        while (i < 4) : (i += 1) {
            _ = try file.write(&[_]u8{ 0xAB, 1, 2, 4, 8, 16, 32, 127, 128 });
        }

        try stdout.print("test file dumped\n", .{});
        return 0;
    }

    if (conf.print_help) {
        try stdout.print("zdump version ???\n", .{});
        try stdout.print("Usage: zdump [OPTIONS] <target file>\n", .{});
        try stdout.print("\n", .{});
        try stdout.print("options:\n", .{});
        try stdout.print("\t--dump-test\tgenerate a binary file for testing\n", .{});
        try stdout.print("\t--help\tprint this help message\n", .{});
        try stdout.print("\t-c <n>\tset the number of columns (default is 16)\n", .{});
        try stdout.print("\t-b <n>\tblock_size: the number of bytes in a block/column\n", .{});
        return 0;
    }

    try stdout.print("dumping file: {s}\n", .{conf.target_file});

    // TODO: Catch and handle errors here
    const file = try std.fs.cwd().openFile(conf.target_file, .{});
    defer file.close();

    const stat = try file.stat();
    const buffer = try allocator.alloc(u8, stat.size);
    defer allocator.free(buffer);
    const bytes_read = try file.readAll(buffer);
    _ = bytes_read;

    // std.debug.print("Buffer Size: {d}", .{buffer.len});

    // wrt block size: 1 column is a full block. so when
    // block_size == 1, 1 column == 1 byte, but when
    // block_size == 2, 1 column == 2 bytes
    var columns: u32 = 0;
    for (buffer) |byte| {
        try stdout.print("{X:02} ", .{byte});

        columns += 1;
        if (columns >= conf.num_columns) {
            try stdout.print("\n", .{});
            columns = 0;
        }
    }

    try stdout.print("\n", .{});

    return 0;
}
