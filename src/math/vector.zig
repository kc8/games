const mUtils = @import("utils.zig");
const std = @import("std");
pub const VF4 = struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,

    pub fn create(x: f32, y: f32, z: f32, w: f32) VF4 {
        return .{
            .x = x,
            .y = y,
            .z = z,
            .w = w,
        };
    }

    pub fn createZeroed() VF4 {
        return VF4.create(0.0, 0.0, 0.0, 0.0);
    }
};

pub const VF3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn create(x: f32, y: f32, z: f32) VF3 {
        return .{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn createZeroed() VF3 {
        return VF3.create(0.0, 0.0, 0.0);
    }

    pub fn format(v: VF3, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeAll("VF3[");
        _ = try writer.print("{d}, {d}, {d}", .{ v.x, v.y, v.z });
        _ = try writer.writeAll("]\n");
    }

    pub fn normalize(v: VF3) VF3 {
        const mag: f32 = magnitude(v);
        if (mag == 0) {
            return v;
        } else {
            const mult = 1.0 / mag;
            return .{
                .x = v.x * mult,
                .y = v.y * mult,
                .z = v.z * mult,
            };
        }
    }
    test "normilize a vf3 computes correctly" {
        const vf3 = VF3.create(20.5, 21.1, 8.5);
        const r = VF3.normalize(vf3);
        // std.debug.print("[INFO] corrected result with {d:.10}, {d:.10}, {d:.10}\n", .{r.x, r.y, r.z});
        const epsilon = 0.00001;
        try std.testing.expect(mUtils.floatCompare(r.x, 0.669, epsilon));
        try std.testing.expect(mUtils.floatCompare(r.y, 0.689, epsilon));
        try std.testing.expect(mUtils.floatCompare(r.z, 0.277, epsilon));
    }

    pub fn sub(a: VF3, b: VF3) VF3 {
        return .{
            .x = a.x - b.x,
            .y = a.y - b.y,
            .z = a.z - b.z,
        };
    }

    pub fn add(a: VF3, b: VF3) VF3 {
        return .{
            .x = a.x + b.x,
            .y = a.y + b.y,
            .z = a.z + b.z,
        };
    }

    pub fn magnitude(v: VF3) f32 {
        const squared: f32 = inner(v, v);
        return @sqrt(squared);
    }
    test "magnitutde a vf3 computes correctly" {
        const vf3 = VF3.create(20.5, 21.1, 8.5);
        const r = VF3.magnitude(vf3);
        const epsilon: f32 = 0.0001;
        const actual: f32 = 30.62;
        const correctedResult = @abs(actual - r);
        //std.debug.print("[INFO] corrected result with {d:.10}\n", .{correctedResult});
        //std.debug.print("[INFO] epsion with {d:.10}\n", .{epsilon});

        try std.testing.expect(epsilon <= correctedResult);
    }

    pub fn inner(a: VF3, b: VF3) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }
    test "inner product of vf3 compuates correctly" {
        const vf3 = VF3.create(20.5, 21.1, 8.5);
        const r = VF3.inner(vf3, vf3);
        //std.debug.print("[INFO] vf3 magnititude with {}\n", .{r});
        try std.testing.expect(r == 937.71);
    }

    pub fn cross(lhs: VF3, rhs: VF3) VF3 {
        return .{
            .x = (lhs.y * rhs.z) - (lhs.z * rhs.y),
            .y = (lhs.z * rhs.x) - (lhs.x * rhs.z),
            .z = (lhs.x * rhs.y) - (lhs.y * rhs.x),
        };
    }
    test "cross product of vf3 with itself is 0" {
        const vf3 = VF3.create(20.5, 21.1, 8.5);
        const r = VF3.cross(vf3, vf3);
        // std.debug.print("[INFO] vf3 magnititude with {}\n", .{r});
        try std.testing.expect((r.x == 0.0));
        try std.testing.expect((r.y == 0.0));
        try std.testing.expect((r.z == 0.0));
    }

    pub fn mulbyF32(v: VF3, m: f32) VF3 {
        return .{
            .x = v.x * m,
            .y = v.y * m,
            .z = v.z * m,
        };
    }
};
