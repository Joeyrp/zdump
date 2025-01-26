// config.zig
// copyright 2025 @ Joseph R. Pollack

const std = @import("std");

pub const Config = struct {
    num_columns: u32 = 16,
    dump_test_file: bool = false,
    target_file: []const u8 = "",

    pub fn init(args: [][:0]u8) !Config {
        // TODO: Config.init()
        // Parse arguments and construct struct
        // For each arg, pass arg to each function
        // in a list of function pointers until one
        // returns true or we run reach the end of the list.
        // Each function represents a config option and
        // attempts to parse the given arg.
        // If none of the optional arg functions process the arg
        // then it will be considered a positional arg.
        var conf = Config{};

        var i: u32 = 1;
        while (i < args.len) {
            for (parse_funcs) |func| {
                const consumed = try func(&conf, i, args);
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
        }

        return conf;
    }
};

const FnType = *const fn (*Config, u32, [][:0]u8) error{ Overflow, InvalidCharacter }!u32;

const parse_funcs: [1]FnType = .{
    parse_num_cols,
};

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
