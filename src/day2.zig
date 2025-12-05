const std = @import("std");
const utils = @import("utils");

fn is_repeating_int_p1(n: usize) !bool {
    const len: usize = @as(usize, std.math.log10(n)) + 1;
    if (len % 2 != 0) return false;

    const pow10 = try std.math.powi(usize, 10, len / 2);
    const last_half: usize = n % pow10;
    const first_half: usize = (n - last_half) / pow10;

    if (first_half == last_half) return true else return false;
}

test "test repeating int part 1" {
    const Case = struct {
        input: usize,
        expect: bool,
    };
    const cases = [_]Case{
        .{ .input = 11, .expect = true },
        .{ .input = 22, .expect = true },
        .{ .input = 99, .expect = true },
        .{ .input = 101, .expect = false },
        .{ .input = 12345678901234567890, .expect = true },
        .{ .input = 1010, .expect = true },
        .{ .input = 999, .expect = false },
    };

    for (cases) |c| {
        const got = try is_repeating_int_p1(c.input);
        if (c.expect != got) {
            std.debug.print("FAILED part 1: input={d}, expected={}, got={}\n", .{ c.input, c.expect, got });
        }
        try std.testing.expectEqual(c.expect, got);
    }
}

fn is_repeating_int_p2(n: usize) bool {
    var buff: [64]u8 = undefined;
    const str = std.fmt.bufPrint(&buff, "{d}", .{n}) catch unreachable;

    for (1..str.len) |pattern_len| {
        if (@rem(str.len, pattern_len) != 0) continue;

        const pattern = str[0..pattern_len];
        var is_repeating = true;

        var k = pattern_len;
        while (k <= str.len - pattern_len) : (k += pattern_len) {
            const part = str[k .. k + pattern_len];
            if (!std.mem.eql(u8, pattern, part)) {
                is_repeating = false;
                break;
            }
        }
        if (is_repeating) return true;
    }
    return false;
}
test "test repeating int part 2" {
    const Case = struct {
        input: usize,
        expect: bool,
    };
    const cases = [_]Case{
        .{ .input = 11, .expect = true },
        .{ .input = 999, .expect = true },
        .{ .input = 1111, .expect = true },

        .{ .input = 1212, .expect = true },
        .{ .input = 1010, .expect = true },
        .{ .input = 9999, .expect = true },

        .{ .input = 123123, .expect = true },
        .{ .input = 12341234, .expect = true },
        .{ .input = 123456123456, .expect = true },

        .{ .input = 123, .expect = false },
        .{ .input = 1234, .expect = false },
        .{ .input = 12345, .expect = false },
        .{ .input = 101, .expect = false },
        .{ .input = 121, .expect = false },
        .{ .input = 1213, .expect = false },
        .{ .input = 123124, .expect = false },
    };

    for (cases) |c| {
        const got = is_repeating_int_p2(c.input);
        if (c.expect != got) {
            std.debug.print("FAILED part 2: input={d}, expected={}, got={}\n", .{ c.input, c.expect, got });
        }
        try std.testing.expectEqual(c.expect, got);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input = try utils.gen_iterator(allocator, "./data/day2.txt", ',');
    // var input = try utils.gen_iterator(allocator, "./data/day2_example.txt", ',');
    defer input.deinit();

    var sum_part1: usize = 0;
    var sum_part2: usize = 0;
    var iter = input.iterator;
    while (iter.next()) |item| {
        // std.debug.print("\nlola: {s}\n", .{item});
        var itr = std.mem.splitScalar(u8, item, '-');

        const range_first_str_raw = itr.next() orelse unreachable;
        const range_first_str = std.mem.trim(u8, range_first_str_raw, " \r\n\t");
        const range_first = try std.fmt.parseInt(usize, range_first_str, 10);

        const range_last_str_raw = itr.next() orelse unreachable;
        const range_last_str = std.mem.trim(u8, range_last_str_raw, " \r\n\t");
        const range_last = try std.fmt.parseInt(usize, range_last_str, 10);

        for (range_first..range_last + 1) |n| {
            if (is_repeating_int_p1(n) catch unreachable) {
                sum_part1 += n;
                std.debug.print("added (part 1): {d}\n", .{n});
            }
            if (is_repeating_int_p2(n)) {
                sum_part2 += n;
                std.debug.print("added (part 2): {d}\n", .{n});
            }
        }
    }
    std.debug.print("\nsolution part 1: {}\nsolution part 2: {}\n", .{ sum_part1, sum_part2 });
}
