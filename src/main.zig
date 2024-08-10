const std = @import("std");
const gl = @cImport({
    @cInclude("glfw3.h");
    @cInclude("gl3.h");
});
const shaders = @import("shaders.zig");
const M4 = @import("math/matrix.zig").M4;
const VF3 = @import("math/vector.zig").VF3;
const math = @import("math/utils.zig");
const opengl = @import("opengl.zig");
const camera = @import("camera.zig");
const GameState = @import("gamestate.zig").GameState;
const renderable = @import("renderable.zig");

pub fn main() !void {
    std.debug.print("Launching 'game time!'\n", .{});
    if (gl.glfwInit() == gl.GL_FALSE) {
        @panic("Could not init GLFW");
    }

    gl.glfwWindowHint(gl.GLFW_CONTEXT_VERSION_MAJOR, 4);
    gl.glfwWindowHint(gl.GLFW_CONTEXT_VERSION_MINOR, 6);
    gl.glfwWindowHint(gl.GLFW_OPENGL_FORWARD_COMPAT, gl.GL_TRUE);
    gl.glfwWindowHint(gl.GLFW_OPENGL_DEBUG_CONTEXT, gl.GL_TRUE); // TODO we dont want this for release
    gl.glfwWindowHint(gl.GLFW_OPENGL_PROFILE, gl.GLFW_OPENGL_CORE_PROFILE);
    gl.glfwWindowHint(gl.GLFW_DEPTH_BITS, 0);
    gl.glfwWindowHint(gl.GLFW_STENCIL_BITS, 8);
    gl.glfwWindowHint(gl.GLFW_RESIZABLE, gl.GL_TRUE);

    var gameState = GameState{
        .isForward = undefined,
        .windowWidth = 800,
        .windowHeight = 800,
    };

    const window = gl.glfwCreateWindow(gameState.windowWidth, gameState.windowHeight, "Game Time", null, null) orelse @panic("Could not create glfw window");
    defer gl.glfwDestroyWindow(window);
    gl.glfwMakeContextCurrent(window);

    _ = gl.glfwSetErrorCallback(opengl.errorCallback);

    const openglInfo = opengl.getCurrentOpenGlInfo();
    std.debug.print("openglInfo'\n", .{});
    std.debug.print("major {}'\n", .{openglInfo.majorVersion});
    std.debug.print("minor {}'\n", .{openglInfo.minorVersion});

    gl.glEnable(gl.GL_DEPTH_TEST);
    gl.glfwSwapInterval(1);

    // build shaders
    const baseVs = try shaders.Shader.createShader(shaders.vs, gl.GL_VERTEX_SHADER);
    const baseFs = try shaders.Shader.createShader(shaders.fs, gl.GL_FRAGMENT_SHADER);
    const programId = gl.glCreateProgram();
    gl.glAttachShader(programId, baseVs);
    gl.glAttachShader(programId, baseFs);
    gl.glLinkProgram(programId);
    if (shaders.Shader.checkCompileLinkError(programId)) |_| {} else |err| switch (err) {
        else => std.debug.print("[ERROR] Failed to link program with id {d} due to error {}'\n", .{ programId, err }),
    }
    const rect = renderable.RenderProperties{
        .programId = programId,
        .elementRenderCount = renderable.getRectRenderCount(),
        .openGlProps = renderable.generateOpenglRect(),
    };
    defer rect.openGlProps.deferMe();

    const cube = renderable.RenderProperties{
        .programId = programId,
        .elementRenderCount = renderable.getCubeRenderCount(),
        .openGlProps = renderable.generateOpenglCube(),
    };
    defer cube.openGlProps.deferMe();

    var viewMatrix = M4.identity;
    var projMatrix = M4.identity;
    const modelMatrix = M4.identity;

    var floatingCamera = camera.Camera.createDefaultCamera();
    floatingCamera.pitchRotate = M4.xRotate(floatingCamera.pitch);
    floatingCamera.yawRotate = M4.xRotate(floatingCamera.yaw);
    floatingCamera.rollRotate = M4.xRotate(floatingCamera.roll);
    floatingCamera.lookAt = camera.computeCameraLookAt(floatingCamera);

    viewMatrix = floatingCamera.lookAt.forward;
    const windowAspectRatio = math.ratio(800, 800);
    projMatrix = camera.computePerspectiveProjection(
        windowAspectRatio,
        floatingCamera.fov,
        floatingCamera.nearClip,
        floatingCamera.farClip,
    );

    opengl.openglCheckError();
    const startTime = gl.glfwGetTime();
    while (gl.glfwWindowShouldClose(window) == gl.GL_FALSE) {
        opengl.getKeyCall(&gameState, window);
        opengl.updateWindowFrameSize(&gameState, window);
        if (gameState.isExit == true) {
            gl.glfwSetWindowShouldClose(window, gl.GL_TRUE);
        }

        gl.glClearColor(0.0, 0.0, 0.0, 0.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT | gl.GL_STENCIL_BUFFER_BIT);

        if (gameState.isForward == true) {
            const movement = VF3.mulbyF32(floatingCamera.forward, -camera.cameraSpeed);
            floatingCamera.worldEyePos = VF3.add(movement, floatingCamera.worldEyePos);
        }
        if (gameState.isBackwards == true) {
            const movement = VF3.mulbyF32(floatingCamera.forward, camera.cameraSpeed);
            floatingCamera.worldEyePos = VF3.add(floatingCamera.worldEyePos, movement);
        }
        if (gameState.isLeft == true) {
            const movement = VF3.mulbyF32(floatingCamera.left, camera.cameraSpeed);
            floatingCamera.worldEyePos = VF3.add(movement, floatingCamera.worldEyePos);
        }
        if (gameState.isRight == true) {
            const movement = VF3.mulbyF32(floatingCamera.left, -camera.cameraSpeed);
            floatingCamera.worldEyePos = VF3.add(movement, floatingCamera.worldEyePos);
        }
        floatingCamera.lookAt = camera.computeCameraLookAt(floatingCamera);
        viewMatrix = floatingCamera.lookAt.forward;
        std.debug.print("VIEW: {}", .{viewMatrix});

        gl.glUseProgram(programId);
        const modelLoc = gl.glGetUniformLocation(programId, "model");
        const viewLoc = gl.glGetUniformLocation(programId, "view");
        const projLoc = gl.glGetUniformLocation(programId, "projection");
        gl.glUniformMatrix4fv(modelLoc, 1, gl.GL_FALSE, &modelMatrix.e[0][0]);
        gl.glUniformMatrix4fv(viewLoc, 1, gl.GL_FALSE, &viewMatrix.e[0][0]);
        gl.glUniformMatrix4fv(projLoc, 1, gl.GL_FALSE, &projMatrix.e[0][0]);

        const timePassedSinceStart = gl.glfwGetTime() - startTime;
        _ = timePassedSinceStart;
        //std.debug.print("[INFO] Timed Passed: {d} '\n", .{gl.glfwGetTime() - startTime});

        //gl.glBindVertexArray(vao);
        //gl.glBindVertexArray(rect.openGlProps.vao);
        gl.glBindVertexArray(cube.openGlProps.vao);
        // TODO is this an issue if our c_int from our u32 wraps around?
        opengl.openglRender(
            cube.elementRenderCount,
            cube.openGlProps.vao,
            cube.openGlProps.ebo,
            cube.openGlProps.vbo,
            );

        gl.glfwSwapBuffers(window);
        gl.glfwPollEvents();
        gl.glViewport(1, 0, gameState.windowWidth, gameState.windowHeight);
        opengl.openglCheckError();
    }
}
