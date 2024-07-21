const std = @import("std");
const gl = @cImport({
    @cInclude("glfw3.h");
    @cInclude("gl3.h");
});
const shaders = @import("shaders.zig");
const M4 = @import("math/matrix.zig").M4;
const opengl = @import("opengl.zig");
const camera = @import("camera.zig");

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

    const window = gl.glfwCreateWindow(800, 800, "Game Time", null, null) orelse @panic("Could not create glfw window");
    defer gl.glfwDestroyWindow(window);
    gl.glfwMakeContextCurrent(window);

    // opengl callbacks
    _ = gl.glfwSetKeyCallback(window, opengl.keyCallback);
    _ = gl.glfwSetErrorCallback(opengl.errorCallback);
    _ = gl.glfwSetFramebufferSizeCallback(window, opengl.frameBufferSizeCallback);

    const openglInfo = opengl.getCurrentOpenGlInfo();
    std.debug.print("openglInfo'\n", .{});
    std.debug.print("major {}'\n", .{openglInfo.majorVersion});
    std.debug.print("minor {}'\n", .{openglInfo.minorVersion});

    gl.glEnable(gl.GL_DEPTH_TEST);
    gl.glViewport(0, 0, 800, 800);
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
    // build buffers
    var vao: gl.GLuint = undefined;
    var vbo: gl.GLuint = undefined;
    var ebo: gl.GLuint = undefined;
    std.debug.print("[INFO] befoer alloc:'\n", .{});
    gl.glGenVertexArrays(1, &vao);
    gl.glGenBuffers(1, &vbo);
    gl.glGenBuffers(1, &ebo);

    gl.glBindVertexArray(vao);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, rectverts.len * @sizeOf(gl.GLfloat), &rectverts, gl.GL_STATIC_DRAW);

    gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, ebo);
    gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, indices.len * @sizeOf(u32), &indices, gl.GL_STATIC_DRAW);

    // pos cords
    gl.glVertexAttribPointer(0, 4, gl.GL_FLOAT, gl.GL_FALSE, 10 * @sizeOf(gl.GLfloat), null);
    gl.glEnableVertexAttribArray(0);
    // colors
    gl.glVertexAttribPointer(1, 4, gl.GL_FLOAT, gl.GL_FALSE, 10 * @sizeOf(gl.GLfloat), @ptrFromInt((4 * @sizeOf(gl.GLfloat))));
    gl.glEnableVertexAttribArray(1);
    // texture coord attribute
    gl.glVertexAttribPointer(2, 2, gl.GL_FLOAT, gl.GL_FALSE, 10 * @sizeOf(gl.GLfloat), @ptrFromInt((8 * @sizeOf(gl.GLfloat))));
    gl.glEnableVertexAttribArray(2);

    defer gl.glDeleteVertexArrays(1, vao);
    defer gl.glDeleteBuffers(1, vbo);

    // defer gl.glfwTerminate(); // throwing a warning

    const viewMatrix = M4.identity;
    _ = viewMatrix;
    const projMatrix = M4.identity;
    const modelMatrix = M4.identity;

    const floatingCamera = camera.Camera.createDefaultCamera();
    const view = floatingCamera.lookAt.forward;

    opengl.openglCheckError();
    const startTime = gl.glfwGetTime();
    while (gl.glfwWindowShouldClose(window) == gl.GL_FALSE) {
        gl.glClearColor(0.0, 0.0, 0.0, 0.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT | gl.GL_STENCIL_BUFFER_BIT);

        gl.glUseProgram(programId);
        const modelLoc = gl.glGetUniformLocation(programId, "model");
        const viewLoc = gl.glGetUniformLocation(programId, "view");
        const projLoc = gl.glGetUniformLocation(programId, "projection");
        gl.glUniformMatrix4fv(modelLoc, 1, gl.GL_FALSE, &modelMatrix.e[0][0]);
        gl.glUniformMatrix4fv(viewLoc, 1, gl.GL_FALSE, &view.e[0][0]);
        gl.glUniformMatrix4fv(projLoc, 1, gl.GL_FALSE, &projMatrix.e[0][0]);

        const timePassedSinceStart = gl.glfwGetTime() - startTime;
        _ = timePassedSinceStart;
        //std.debug.print("[INFO] Timed Passed: {d} '\n", .{gl.glfwGetTime() - startTime});

        gl.glBindVertexArray(vao);
        gl.glDrawElements(gl.GL_TRIANGLES, 6, gl.GL_UNSIGNED_INT, null);

        gl.glfwSwapBuffers(window);
        gl.glfwPollEvents();
        opengl.openglCheckError();
    }
}

const indices = [_]u32{ 0, 1, 3, 1, 2, 3 };
const rectverts = [_]gl.GLfloat{
    // positions        // colors     // texture coords
    0.5, 0.5, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, // top right
    0.5, -0.5, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, // bottom right
    -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, // bottom left
    -0.5, 0.5,  0.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, // top left
};

const cubeVerts = [_]gl.GLfloat{};
