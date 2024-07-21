const zMath = @import("std").math;
const std = @import("std");

pub const M4 = struct {
    e: [4][4]f32,

    pub const identity = M4{ .e = [4][4]f32{
        [4]f32{ 1.0, 0.0, 0.0, 0.0 },
        [4]f32{ 0.0, 1.0, 0.0, 0.0 },
        [4]f32{ 0.0, 0.0, 1.0, 0.0 },
        [4]f32{ 0.0, 0.0, 0.0, 1.0 },
    } };

    pub fn format(m4: M4, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeAll("M4{{\n");
        for (m4.e) |elem| {
            _ = try writer.print("[", .{});
            for (elem) |k| {
                _ = try writer.print(" {d} ", .{k});
            }
            _ = try writer.print("]\n", .{});
        }

        _ = try writer.print("}}\n", .{});
    }
};

pub const M4INV = struct {
    inverse: M4,
    forward: M4,
};

pub fn orthographicProjection(aspectWdithOverHeight: f32, nearClip: f32, farClip: f32) M4INV {
    const a = 1.0;
    const b = aspectWdithOverHeight;
    const n = nearClip;
    const f = farClip;

    const d = 2.0 / (n - f);
    const e = (n + f) / (n - f);

    const result: M4INV = M4INV{
        .forward = M4{
            .e = [4][4]f32{
                [4]f32{ a, 0, 0, 0 },
                [4]f32{ 0, b, 0, 0 },
                [4]f32{ 0, 0, d, e },
                [4]f32{ 0, 0, 0, 1 },
            },
        },
        .inverse = M4{
            .e = [4][4]f32{
                [4]f32{ 1 / a, 0, 0, 0 },
                [4]f32{ 0, 1 / b, 0, 0 },
                [4]f32{ 0, 0, 1 / d, -e / d },
                [4]f32{ 0, 0, 0, 1 },
            },
        },
    };
    return result;
}

pub fn perspectiveProjection(aspectRatio: f32, focalLength: f32, nearClip: f32, farClip: f32) M4 {
    const ar = aspectRatio;
    const fov = focalLength; // NOTE focal length is field of view

    const n = nearClip;
    const f = farClip;

    const nearZRange: f32 = n - f;
    //Calculate Depth
    const A: f32 = (-f - n) / (nearZRange);
    const B: f32 = (2 * n * f) / (nearZRange); //-51 was the value that seemed to work

    // FOV calculations and how much of the area we can see
    // Also considered zoom
    const halfFov: f32 = zMath.degreesToRadians((fov / 2.0));
    const tanHalfFOV: f32 = @tan(halfFov);
    //NOTE will ar change if monitor width > its height?
    const x: f32 = (1.0 / (tanHalfFOV * ar));
    const y: f32 = (1.0 / tanHalfFOV);

    const result: M4 = M4{
        // NOTE I believe x/ar and y are correct here. the other functions,
        // not so much -100.0f allows us to view the rectangle
        .e = [4][4]f32{
            [4]f32{ x, 0.0, 0.0, 0.0 },
            [4]f32{ 0.0, y, 0.0, 0.0 },
            [4]f32{ 0.0, 0.0, A, B }, // 5.0f gives uss what we are looking for but how come we cant get it
            [4]f32{ 0.0, 0.0, 1.0, 0.0 },
        },
    };
    return result;
}

test "perspectiveCompiles: test does not check if correct" {
    const proj = perspectiveProjection(1.0, 1.0, 2.0, 1.0);
    std.debug.print("[INFO] projection matrix returned with: {}\n", .{proj});
    try std.testing.expect(proj.e[0][0] == 114.588646);
}

test "orthoo graphical projection: test does not check if correct" {
    const proj = orthographicProjection(1.0, 1.0, 2.0);
    const inv = proj.inverse;
    const forward = proj.forward;

    std.debug.print("[INFO] orotho inverse matrix returned with: {}\n", .{inv});
    std.debug.print("[INFO] orotho forward matrix returned with: {}\n", .{forward});
    try std.testing.expect(forward.e[0][0] == 1);
    try std.testing.expect(inv.e[0][0] == 1);
}
