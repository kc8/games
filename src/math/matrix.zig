const zMath = @import("std").math;
const VF3 = @import("vector.zig").VF3;
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

    pub fn transpose(m: M4) M4 {
        var result: M4 = M4.identity;

        for (0..4) |j| {
            for (0..4) |i| {
                result.e[j][i] = m.e[i][j];
            }
        }
        return result;
    }

    pub fn translation(t: VF3) M4 {
        return .{
            .e = [4][4]f32{
                [4]f32{ 1, 0, 0, t.x },
                [4]f32{ 0, 1, 0, t.y },
                [4]f32{ 0, 0, 1, t.z },
                [4]f32{ 0, 0, 0, 1 },
            },
        };
    }

    pub fn mul(a: M4, b: M4) M4 {
        var result: M4 = M4.identity;
        for (0..4) |y| {
            for (0..4) |x| {
                result.e[y][x] =
                    (a.e[y][0] * b.e[0][x]) +
                    (a.e[y][1] * b.e[1][x]) +
                    (a.e[y][2] * b.e[2][x]) +
                    (a.e[y][3] * b.e[3][x]);
            }
        }
        return result;
    }
    test "mul matrix4 computes identity when against identity" {
        const a = M4.identity;
        const b = M4.identity;
        const result = M4.mul(a, b);
        const actual = M4.identity;
        for (0..4) |i| {
            for (0..4) |k| {
                try std.testing.expect(result.e[i][k] == actual.e[i][k]);
            }
        }
        //std.debug.print("[INFO] matrix returned with: {}\n", .{result});
    }

    pub fn xRotate(a: f32) M4 {
        const c = @cos(a);
        const s = @sin(a);
        return .{
            .e = [4][4]f32{
                [4]f32{ 1, 0, 0, 0 },
                [4]f32{ 0, c, -s, 0 },
                [4]f32{ 0, s, c, 0 },
                [4]f32{ 0, 0, 0, 1 },
            },
        };
    }

    pub fn yRotate(a: f32) M4 {
        const c = @cos(a);
        const s = @sin(a);
        return .{
            .e = [4][4]f32{
                [4]f32{ c, 0, s, 0 },
                [4]f32{ 0, 1, 0, 0 },
                [4]f32{ -s, 0, c, 0 },
                [4]f32{ 0, 0, 0, 1 },
            },
        };
    }
    pub fn zRotate(a: f32) M4 {
        const c = @cos(a);
        const s = @sin(a);
        return .{
            .e = [4][4]f32{
                [4]f32{ c, -s, 0, 0 },
                [4]f32{ s, c, 0, 0 },
                [4]f32{ 0, 0, 1, 0 },
                [4]f32{ 0, 0, 0, 1 },
            },
        };
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

test "orthoo graphical projection: test does not check if correct" {
    const proj = orthographicProjection(1.0, 1.0, 2.0);
    const inv = proj.inverse;
    const forward = proj.forward;

    //std.debug.print("[INFO] orotho inverse matrix returned with: {}\n", .{inv});
    //std.debug.print("[INFO] orotho forward matrix returned with: {}\n", .{forward});
    try std.testing.expect(forward.e[0][0] == 1);
    try std.testing.expect(inv.e[0][0] == 1);
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
    //std.debug.print("[INFO] projection matrix returned with: {}\n", .{proj});
    try std.testing.expect(proj.e[0][0] == 114.588646);
}
