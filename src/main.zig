//! File:   main.zig
//! Author: Joseph R Pollack
//! Copyright 2025
//!
//! dumps the binary data from a given file

// TODO: Use NotCurses to make an interactive ui

const std = @import("std");

pub fn main() !u8 {

    // TEMP:
    // Code from: ratfactor, here:
    // https://ziggit.dev/t/read-command-line-arguments/220/7

    // Get allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    // Parse args into string array
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Get and print them!
    // std.debug.print("There are {d} args:\n", .{args.len});
    // for (args) |arg| {
    //     std.debug.print("    {s}\n", .{arg});
    // }

    if (args.len < 2) {
        std.debug.print("Error: Expected filename\n", .{});
        return 1;
    }

    if (std.mem.eql(u8, args[1], "--dump-test")) {
        const file = try std.fs.cwd().createFile("test_file", .{ .read = true });
        defer file.close();

        _ = try file.write(&[_]u8{ 0xAB, 1, 2, 4, 8, 16, 32, 127, 128 });

        std.debug.print("test file dumped\n", .{});
        return 0;
    }

    // const cwd = try std.fs.selfExeDirPathAlloc(allocator);
    // defer allocator.free(cwd);
    // const opt_cwd_path = std.fs.path.dirname(cwd);

    // if (opt_cwd_path) |real_path| {
    //     std.debug.print("program dir: {s}\n", .{real_path});
    // }

    // const cwd_path = try std.fs.cwd().realpathAlloc(allocator, ".");
    // defer allocator.free(cwd_path);
    // std.debug.print("working dir: {s}\n", .{cwd_path});

    std.debug.print("dumping file: {s}\n", .{args[1]});

    // WORKS!
    // std.debug.print("TEST PRINT: {x:02} {x:02} {x:02} {x:02} \n", .{ 5, 16, 32, 128 });

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    const stat = try file.stat();
    const buffer = try allocator.alloc(u8, stat.size);
    defer allocator.free(buffer);
    const bytes_read = try file.readAll(buffer);
    _ = bytes_read;

    for (buffer) |byte| {
        std.debug.print("{X:02} ", .{byte});
    }

    std.debug.print("\n", .{});

    return 0;
}
