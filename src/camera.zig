const M4 = @import("math/matrix.zig").M4;
const M4INV = @import("math/matrix.zig").M4INV;
const VF3 = @import("math/vector.zig").VF3;

pub const Camera = struct {
    target: M4,
    worldyePos: M4,

    up: VF3,
    left: VF3,
    forward: VF3,

    pitchRotate: M4,
    yawRotate: M4,
    rollRotate: M4,

    cameraAngle: VF3,

    pitch: f32,
    yaw: f32,
    roll: f32,

    lookAt: M4INV,

    nearClip: f32,
    farClip: f32,
    fov: f32,

    view: M4,
};
