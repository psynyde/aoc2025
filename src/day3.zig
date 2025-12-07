const std = @import("std");
const utils = @import("utils");

fn get_joltage(allocator: std.mem.Allocator, line: []const u8, digits: u8) !usize {
    var number = try std.ArrayList(u8).initCapacity(allocator, digits);
    defer number.deinit(allocator);

    // try number.appendNTimes(allocator, 0, number.capacity);
    var index: usize = 0;
    for (0..number.capacity) |_| {
        defer index += 1;
        try number.append(allocator, line[index]);
    }
    // std.debug.print("line: {s} - number: {s} - index @: {} aka {c}\n", .{
    //     line,
    //     number.items,
    //     index,
    //     line[index],
    // });

    const number_len = number.items.len - 1;
    for (line[index..]) |item| {
        defer index += 1;
        // retrived each number from input to "item"
        if (item > number.items[number_len]) {
            // set the last digit to item if it's bigger. push it to the stream.
            number.items[number_len] = item;
        }
        // std.debug.print("@{c}\n", .{item});
        // (line.len - 1) - index = number of items left to check.
        // generally number of item left is > number_len. but when it gets less than number_len i want to
        // use that number as 0..number of item left.
        // so the bound in the for loop below can be highest number_len but then number of items left
        const items_left = (line.len - 1) - index;
        // std.debug.print("imtes left : {}\n", .{items_left});
        const bound = @min(number_len, items_left);
        for (0..bound) |i| {
            // compare through the number to see if the previous digit is bigger.
            if (number.items[number_len - 1 - i] < number.items[number_len - i]) {
                number.items[number_len - 1 - i] = number.items[number_len - i];
                number.items[number_len - i] = 0;
                // std.debug.print("big: {c} > {c}\n", .{
                //     number.items[number_len - i],
                //     number.items[number_len - 1 - i],
                // });
            }
        }
    }
    // std.debug.print("biggest possible number: {s}\n", .{number.items});
    // 7 6 2 4 8 0 2 9
    // before pushing a u8 ahead make sure there's enough elements left to fill.
    // (line.len - 1) - index = items left
    // if (item + 1 > item) && (items left >= line.len) push to item.
    const result = try std.fmt.parseInt(usize, number.items, 10);
    return result;
}

// Find the largest digit in the remaining string that still leaves enough characters
// to fill the remaining positions then add that digit to result and continue from
// the next position after it.
fn get_joltage_v2(allocator: std.mem.Allocator, line: []const u8, digits: u8) !usize {
    var result = try std.ArrayList(u8).initCapacity(allocator, digits);
    defer result.deinit(allocator);

    var start_pos: usize = 0;

    for (0..digits) |pos| {
        const remaining_needed = digits - pos - 1;
        const search_end = line.len - remaining_needed;

        var max_digit: u8 = '0';
        var max_pos: usize = start_pos;

        for (start_pos..search_end) |i| {
            if (line[i] > max_digit) {
                max_digit = line[i];
                max_pos = i;
            }
        }

        try result.append(allocator, max_digit);
        start_pos = max_pos + 1;
    }

    return try std.fmt.parseInt(usize, result.items, 10);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var input = try utils.gen_iterator(allocator, "./data/day3.txt", '\n');
    // var input = try utils.gen_iterator(allocator, "./data/day3_example.txt", '\n');
    defer input.deinit();

    var iter = input.iterator;

    var solution_p1: usize = 0;
    var solution_p2: usize = 0;
    while (iter.next()) |items| {
        if (items.len == 0) continue;
        const result_p1 = try get_joltage(allocator, items, 2);
        solution_p1 += result_p1;

        const result_p2 = try get_joltage_v2(allocator, items, 12);
        solution_p2 += result_p2;
    }
    std.debug.print("result1: {} result_2: {}\n", .{ solution_p1, solution_p2});
}
