const std = @import("std");
const gl = @cImport({
    @cInclude("glfw3.h");
    @cInclude("gl3.h");
});

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
    return .{ .majorVersion = major, .minorVersion = minor, .vendor = vendor, .renderer = renderer, .version = version, .shadingLangVer = shadringLangVer };
}

pub fn errorCallback(err: c_int, desc: [*c]const u8) callconv(.C) void {
    std.debug.print("err num: {d} err desc: {s} '\n", .{ err, desc });
}

pub fn keyCallback(
    win: ?*gl.GLFWwindow,
    key: c_int,
    scancode: c_int,
    action: c_int,
    mods: c_int,
) callconv(.C) void {
    _ = mods;
    _ = scancode;

    if (action == gl.GLFW_PRESS) {
        switch (key) {
            gl.GLFW_KEY_ESCAPE => gl.glfwSetWindowShouldClose(win, gl.GL_TRUE),
            else => {},
        }
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
