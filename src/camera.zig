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

    pub fn createDefaultCamera() Camera {
        var c: Camera = .{
            .nearClip = 100.0,
            .farClip = 1.0,
            .fov = 45.0,
            .up = VF3.create(0.0, 1.0, 0.0),
            .target = VF3.create(0.0, 0.0, -1.0),
            .worldEyePos = VF3.create(0.0, 0.0, -10.0),
            .yawRotate = M4.identity,
            .rollRotate = M4.identity,
            .pitchRotate = M4.identity,
            .cameraAngle = VF3.createZerod(),
            .view = M4.identity,
        };

        c.forward = computeCameraForward();
        c.left = computeCameraLeft();
        c.up = computeCameraUp();
        c.lookAt = computeCameraUp();

        return c;
    }
};

fn computeCameraForward(cameraEyePos: VF3, cameraTarget: VF3) VF3 {
    return .{
        .e = VF3.normalize(VF3.sub(cameraEyePos, cameraTarget)),
    };
}

fn computeCameraLeft(up: VF3, forward: VF3) VF3 {
    return .{
        .e = VF3.normalize(VF3.cross(up, forward)),
    };
}

fn computeCameraUp(forward: VF3, left: VF3) VF3 {
    return VF3.cross(forward, left);
}

fn ComputeCameraLookAt(eye: VF3, pitchRotate: M4, 
    yawRotate: M4, rollRotate: M4, up: VF3, 
    forward: VF3, left: VF3) VF3 {

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

    result.forward = result.forward * pitchRotate;
    result.forward = result.forward * yawRotate;
    result.forward = result.forward * rollRotate;
    result.forward = result.forward * translation;
    result.forward = M4.transpose(result.forward);
    return result;
}
