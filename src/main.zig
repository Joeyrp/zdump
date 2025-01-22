//! File:   main.zig
//! Author: Joseph R Pollack
//! Copyright 2025
//!
//! dumps the binary data from a given file

const std = @import("std");

pub fn main() !void {

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
    std.debug.print("There are {d} args:\n", .{args.len});
    for (args) |arg| {
        std.debug.print("    {s}\n", .{arg});
    }
}
