const std = @import("std");
const utils = @import("utils");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input = try utils.gen_iterator(allocator, "./data/day1.txt", '\n');
    // var data_struct = try utils.gen_iterator(allocator, "./data/day1_example.txt");
    defer input.deinit();

    var iter = input.iterator;
    var pointer: isize = 50;
    var pass_1: usize = 0;
    var pass_2: usize = 0;

    while (iter.next()) |item| {
        const saved_pos = pointer;
        var distance: isize = 0;

        if (std.mem.startsWith(u8, item, "R")) {
            const num = try std.fmt.parseInt(isize, item[1..], 10);
            distance = num;
        } else if (std.mem.startsWith(u8, item, "L")) {
            const num = try std.fmt.parseInt(isize, item[1..], 10);
            distance = -num;
        } else {
            continue;
        }

        const full_cycles = @abs(@divTrunc(distance, 100));
        pass_2 += @intCast(full_cycles);

        const rem_dist = @rem(distance, 100);

        if (saved_pos + rem_dist > 100) {
            pass_2 += 1;
        }
        if (saved_pos + rem_dist < 0 and saved_pos != 0) {
            pass_2 += 1;
        }

        pointer = @mod(saved_pos + rem_dist, 100);

        if (pointer == 0) {
            pass_1 += 1;
            pass_2 += 1;
        }
        std.debug.print("pointer: {}\n", .{pointer});
    }

    std.debug.print("\npass part 1: {}\npass part 2: {}\n", .{ pass_1, pass_2 });
}
