const std = @import("std");

pub fn build(b: *std.Build) void{
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "game time",
        .root_source_file =  b.path("src/main.zig"),
        .optimize = optimize,
        .target = target,
    });
    exe.linkLibC();

    //glfw3
    const glfwInclude = "third_party/glfw-include/include";
    exe.addIncludePath(b.path(glfwInclude));
    //exe.addObjectFile(b.path("third_party/glfw-include/libglfw3.a"));
    exe.linkSystemLibrary("glfw3");

    // opengl headers and libs
    exe.addIncludePath(b.path("third_party/gl"));
    exe.linkSystemLibrary("GLU");
    exe.linkSystemLibrary("X11");
    exe.linkSystemLibrary("GL");

    b.installArtifact(exe);

    const play = b.step("run", "run exe");
    const run = b.addRunArtifact(exe);
    run.step.dependOn(b.getInstallStep());
    play.dependOn(&run.step);
}
