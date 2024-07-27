const math = @import("math/utils.zig");
const M4 = @import("math/matrix.zig").M4;
const M4INV = @import("math/matrix.zig").M4INV;
const VF3 = @import("math/vector.zig").VF3;

pub const cameraSpeed = 0.05;
pub const cameraMOuseSpeed = 0.0005;

pub const Camera = struct {
    target: VF3,
    worldEyePos: VF3,

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

    pub fn createDefaultCamera() Camera {
        var c: Camera = Camera{
            .nearClip = 100.0,
            .pitch = 1.0,
            .yaw = 1.0,
            .roll = 1.0,
            .farClip = 1.0,
            .fov = 45.0,
            .up = VF3.create(0.0, 1.0, 0.0),
            .target = VF3.create(0.0, 0.0, -1.0),
            .worldEyePos = VF3.create(0.0, 0.0, -10.0),
            .yawRotate = M4.identity,
            .rollRotate = M4.identity,
            .pitchRotate = M4.identity,
            .cameraAngle = VF3.createZeroed(),
            .view = M4.identity,
            .forward = VF3.createZeroed(),
            .left = VF3.createZeroed(),
            .lookAt = undefined,
        };

        c.forward = computeCameraForward(c.worldEyePos, c.target);
        c.left = computeCameraLeft(c.up, c.forward);
        c.up = computeCameraUp(c.forward, c.left);
        c.lookAt = computeCameraLookAt(c);
        return c;
    }
};

pub fn computeCameraForward(cameraEyePos: VF3, cameraTarget: VF3) VF3 {
    return VF3.normalize(VF3.sub(cameraEyePos, cameraTarget));
}

pub fn computeCameraLeft(up: VF3, forward: VF3) VF3 {
    return VF3.normalize(VF3.cross(up, forward));
}

pub fn computeCameraUp(forward: VF3, left: VF3) VF3 {
    return VF3.cross(forward, left);
}

// note: dont mutate the camera.... return new mat
pub fn computeCameraLookAt(c: Camera) M4INV {
    const eye = c.worldEyePos;
    const pitchRotate = c.pitchRotate;
    const yawRotate = c.yawRotate;
    const rollRotate = c.rollRotate;
    const up = c.up;
    const forward = c.forward;
    const left = c.left;

    const forwardMat: M4 = M4{
        .e = [4][4]f32{
            [4]f32{ left.x, left.y, left.z, 0 },
            [4]f32{ up.x, up.y, up.z, 0 },
            [4]f32{ forward.x, forward.y, forward.z, 0 },
            [4]f32{ 0, 0, 0, 1 },
        },
    };

    const inverse: M4 = M4{
        .e = [4][4]f32{
            [4]f32{ left.x, up.x, forward.x, 0 },
            [4]f32{ left.y, up.y, forward.y, 0 },
            [4]f32{ left.z, up.z, forward.z, 0 },
            [4]f32{ 0, 0, 0, 1 },
        },
    };

    var result: M4INV = .{
        .forward = forwardMat,
        .inverse = inverse,
    };

    const translation: M4 = M4.translation(eye);

    result.forward = M4.mul(result.forward, pitchRotate);
    result.forward = M4.mul(result.forward, yawRotate);
    result.forward = M4.mul(result.forward, rollRotate);
    result.forward = M4.mul(result.forward, translation);
    result.forward = M4.transpose(result.forward);
    return result;
}

pub fn computePerspectiveProjection(
    aspectRatio: f32,
    focalLength: f32,
    nearClip: f32,
    farClip: f32,
) M4 {
    const ar: f32 = aspectRatio;
    const fov: f32 = focalLength; // NOTE focal length is field of view

    const n: f32 = nearClip;
    const f: f32 = farClip;

    const nearZRange: f32 = n - f;
    //Calculate Depth
    const A: f32 = (-f - n) / (nearZRange);
    const B: f32 = (2 * n * f) / (nearZRange); //-51 was the value that seemed to work

    // FOV calculations and how much of the area we can see
    // Also considered zoom
    const halfFov: f32 = math.toRadians((fov / 2.0));
    const tanHalfFOV: f32 = math.tan32(halfFov);
    //NOTE will ar change if monitor width > its height?
    const x: f32 = (1.0 / (tanHalfFOV * ar)); // NOTE we were dividing by ar
    const y: f32 = (1.0 / tanHalfFOV);

    // NOTE I believe x/ar and y are correct here. the other functions,
    // not so much -100.0f allows us to view the rectangle
    const result: M4 = M4{
        .e = [4][4]f32{
            [4]f32{ x, 0.0, 0.0, 0.0 },
            [4]f32{ 0.0, y, 0.0, 0.0 },
            [4]f32{ 0.0, 0.0, A, B }, // 5.0f gives uss what we are looking for but how come we cant get it
            [4]f32{ 0.0, 0.0, 1.0, 0.0 },
        },
    };
    return result;
}
