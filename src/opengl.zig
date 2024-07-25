const std = @import("std");
const gl = @cImport({
    @cInclude("glfw3.h");
    @cInclude("gl3.h");
});
const GameState = @import("gamestate.zig").GameState;

const OpenglInfo = struct {
    majorVersion: c_int,
    minorVersion: c_int,
    vendor: [*:0]const u8,
    renderer: [*:0]const u8,
    version: [*:0]const u8,
    shadingLangVer: [*:0]const u8,
};

pub fn getCurrentOpenGlInfo() OpenglInfo {
    const vendor = gl.glGetString(gl.GL_VENDOR);
    const renderer = gl.glGetString(gl.GL_RENDERER);
    const version = gl.glGetString(gl.GL_VERSION);
    const shadringLangVer = gl.glGetString(gl.GL_SHADING_LANGUAGE_VERSION);

    var major: gl.GLint = undefined;
    var minor: gl.GLint = undefined;
    gl.glGetIntegerv(gl.GL_MAJOR_VERSION, &major);
    gl.glGetIntegerv(gl.GL_MINOR_VERSION, &minor);
    return .{
        .majorVersion = major,
        .minorVersion = minor,
        .vendor = vendor,
        .renderer = renderer,
        .version = version,
        .shadingLangVer = shadringLangVer,
    };
}

pub fn errorCallback(err: c_int, desc: [*c]const u8) callconv(.C) void {
    std.debug.print("err num: {d} err desc: {s} '\n", .{ err, desc });
}

pub fn getKeyCall(gameState: *GameState, win: ?*gl.GLFWwindow) void {
    if (gl.glfwGetKey(win, gl.GLFW_KEY_ESCAPE) == gl.GLFW_PRESS) {
        gameState.isExit = true;
    }
    // PRESS
    if (gl.glfwGetKey(win, gl.GLFW_KEY_W) == gl.GLFW_PRESS) {
        gameState.isForward = true;
    }
    if (gl.glfwGetKey(win, gl.GLFW_KEY_S) == gl.GLFW_PRESS) {
        gameState.isBackwoards= true;
    }
    if (gl.glfwGetKey(win, gl.GLFW_KEY_D) == gl.GLFW_PRESS) {
        gameState.isRight = true;
    }
    if (gl.glfwGetKey(win, gl.GLFW_KEY_A) == gl.GLFW_PRESS) {
        gameState.isLeft = true;
    }
    // RELEASE
    if (gl.glfwGetKey(win, gl.GLFW_KEY_W) == gl.GLFW_RELEASE) {
        gameState.isForward = false;
    }
    if (gl.glfwGetKey(win, gl.GLFW_KEY_S) == gl.GLFW_RELEASE) {
        gameState.*.isBackwoards = false;
    }
    if (gl.glfwGetKey(win, gl.GLFW_KEY_D) == gl.GLFW_RELEASE) {
        gameState.isRight = false;
    }
    if (gl.glfwGetKey(win, gl.GLFW_KEY_A) == gl.GLFW_RELEASE) {
        gameState.isLeft = false;
    }
}

pub fn frameBufferSizeCallback(
    win: ?*gl.GLFWwindow,
    width: c_int,
    height: c_int,
) callconv(.C) void {
    _ = width;
    _ = height;
    _ = win;
}

pub fn openglCheckError() void {
    const err = gl.glGetError();
    if (err != gl.GL_NO_ERROR) {
        std.debug.print("[ERROR] Opengl Error: {d}\n", .{err});
    }
}
