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

fn getOpenglInfo() OpenglInfo {
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

fn errorCallback(err: c_int, desc: [*c]const u8) callconv(.C) void {
    std.debug.print("err num: {d} err desc: {s} '\n", .{ err, desc });
}

fn keyCallback(
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

pub fn main() !void {
    std.debug.print("Launching 'game time!'\n", .{});
    if (gl.glfwInit() == gl.GL_FALSE) {
        @panic("Could not init GLFW");
    }

    gl.glfwWindowHint(gl.GLFW_CONTEXT_VERSION_MAJOR, 4);
    gl.glfwWindowHint(gl.GLFW_CONTEXT_VERSION_MINOR, 6);
    gl.glfwWindowHint(gl.GLFW_OPENGL_FORWARD_COMPAT, gl.GL_TRUE);
    //.glfwWindowHint(gl.GLFW_OPENGL_DEBUG_CONTEXT, gl.is_on);
    gl.glfwWindowHint(gl.GLFW_OPENGL_PROFILE, gl.GLFW_OPENGL_CORE_PROFILE);
    gl.glfwWindowHint(gl.GLFW_DEPTH_BITS, 0);
    gl.glfwWindowHint(gl.GLFW_STENCIL_BITS, 8);
    gl.glfwWindowHint(gl.GLFW_RESIZABLE, gl.GL_FALSE);

    const window = gl.glfwCreateWindow(800, 800, "Game Time", null, null) orelse @panic("Could not create glfw window");
    defer gl.glfwDestroyWindow(window);
    gl.glfwMakeContextCurrent(window);

    _ = gl.glfwSetKeyCallback(window, keyCallback);
    _ = gl.glfwSetErrorCallback(errorCallback);

    const openglInfo = getOpenglInfo();
    std.debug.print("openglInfo'\n", .{});
    std.debug.print("major {}'\n", .{openglInfo.majorVersion});
    std.debug.print("minor {}'\n", .{openglInfo.minorVersion});

    gl.glClearColor(1.0, 0.0, 0.0, 1.0);
    gl.glViewport(0, 0, 800, 800);
    gl.glfwSwapInterval(1);
    //const startTime = gl.glfwGetTime();

    while (gl.glfwWindowShouldClose(window) == gl.GL_FALSE) {
        //while (gl.glfwWindowShouldClose(window) == gl.GL_FALSE) {
        //while (true) {
        gl.glfwSwapBuffers(window);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT | gl.GL_STENCIL_BUFFER_BIT);
        gl.glfwPollEvents();
        //std.debug.print("time: {}'\n", .{gl.glfwGetTime()});
    }
}
