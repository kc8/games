const zMath = @import("std").math;

pub inline fn floatCompare(a: f32, b: f32, ep: f32) bool {
    const correctedResult = @abs(b - a);
    return ep <= correctedResult;
}

pub inline fn toRadians(a: f32) f32 {
    return zMath.degreesToRadians(a);
}

pub inline fn tan32(a: f32) f32 {
    return @tan(a);
}

pub fn ratio(n: f32, d: f32) f32 {
    if (d == 0) {
        @panic("You cannot pass the ratio function a divisor of 0");
    }
    return n / d;
}
