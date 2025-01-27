// config.zig
// copyright 2025 @ Joseph R. Pollack

const std = @import("std");

pub const Config = struct {
    num_columns: u32 = 16,
    dump_test_file: bool = false,
    print_help: bool = false,
    target_file: []const u8 = "",
    block_size: u32 = 1,

    pub fn init(args: [][:0]u8) !Config {
        var conf = Config{};

        var i: u32 = 1;
        while (i < args.len) {
            const consumed = try check_optionals(&conf, i, args);
            if (consumed > 0) {
                i += consumed;
                continue;
            }

            // Handle positional args
            if (std.mem.eql(u8, conf.target_file, "")) {
                conf.target_file = args[i];
            } else {
                std.debug.print("Warning: Unexpected positional argument: {s}, ignoring.\n", .{args[i]});
            }

            i += 1;
        }

        return conf;
    }
};

fn check_optionals(conf: *Config, at: u32, args: [][:0]u8) !u32 {
    for (parse_funcs) |func| {
        const consumed = try func(conf, at, args);
        if (consumed > 0) {
            return consumed;
        }
    }

    return 0;
}

const FnType = *const fn (*Config, u32, [][:0]u8) error{ Overflow, InvalidCharacter }!u32;

const parse_funcs: [4]FnType = .{ parse_num_cols, parse_block_size, parse_dump_test_file, parse_help };

// Returns the number of "args" consumed
fn parse_num_cols(conf: *Config, at: u32, args: [][:0]u8) !u32 {
    var idx = at;
    if (std.mem.eql(u8, args[idx], "-c")) {
        idx += 1;
        conf.num_columns = try std.fmt.parseInt(u32, args[idx], 10);
        return 2;
    }

    return 0;
}

fn parse_block_size(conf: *Config, at: u32, args: [][:0]u8) !u32 {
    var idx = at;
    if (std.mem.eql(u8, args[idx], "-b")) {
        idx += 1;
        conf.block_size = try std.fmt.parseInt(u32, args[idx], 10);
        return 2;
    }

    return 0;
}

fn parse_dump_test_file(conf: *Config, at: u32, args: [][:0]u8) !u32 {
    const idx = at;
    if (std.mem.eql(u8, args[idx], "--dump-test")) {
        conf.dump_test_file = true;
        return 1;
    }

    return 0;
}

fn parse_help(conf: *Config, at: u32, args: [][:0]u8) !u32 {
    const idx = at;
    if (std.mem.eql(u8, args[idx], "-h")) {
        conf.print_help = true;
        return 1;
    }
    if (std.mem.eql(u8, args[idx], "--help")) {
        conf.print_help = true;
        return 1;
    }

    return 0;
}
