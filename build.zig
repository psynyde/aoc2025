const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const allocator = std.heap.page_allocator;

    const utils_mod = b.addModule("utils", .{
        .root_source_file = b.path("src/utils.zig"),
        .target = target,
    });

    var cwd = std.fs.cwd();
    var src_dir = try cwd.openDir("src", .{ .iterate = true });
    defer src_dir.close();

    var walker = try src_dir.walk(allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        if (entry.kind != .file) continue;
        const name = entry.basename; // e.g. "day1.zig"

        if (!std.mem.startsWith(u8, name, "day")) continue;
        if (!std.mem.endsWith(u8, name, ".zig")) continue;

        const file_base_name = name[0 .. name.len - 4];

        const file_path = try std.fmt.allocPrint(allocator, "src/{s}", .{name});
        defer allocator.free(file_path);

        // create a root module for the executable and import the utils module
        const root_mod = b.createModule(.{
            .root_source_file = b.path(file_path),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "utils", .module = utils_mod },
            },
        });

        const exe = b.addExecutable(.{
            .name = file_base_name,
            .root_module = root_mod,
        });
        b.installArtifact(exe);

        const run_artifact = b.addRunArtifact(exe);

        const step_name = try std.fmt.allocPrint(allocator, "run_{s}", .{file_base_name});
        defer allocator.free(step_name);

        const step_desc = try std.fmt.allocPrint(allocator, "Runs Advent of code {s} solution", .{file_base_name});
        defer allocator.free(step_desc);

        const run_step = b.step(step_name, step_desc);
        run_step.dependOn(&run_artifact.step);

        run_artifact.step.dependOn(b.getInstallStep());

        // `zig build run_dayN -- arg1 arg2`
        if (b.args) |args| {
            run_artifact.addArgs(args);
        }
    }
}
