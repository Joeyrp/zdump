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

    const dir = std.fs.cwd().realpathAlloc(allocator, "I dunno what this is for {!}");
    std.debug.print("dumping file:{s}/{s}\n", .{ dir, args[1] });

    // WORKS!
    std.debug.print("TEST PRINT: {x:02} {x:02} {x:02} {x:02} \n", .{ 5, 16, 32, 128 });

    // const file = try std.fs.cwd().openFile(args[1], .{});
    // defer file.close();

    return 0;
}
