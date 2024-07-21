const gl = @cImport({
    @cInclude("glfw3.h");
    @cInclude("gl3.h");
});
const std = @import("std");

pub const vs: []const u8 =
    \\#version 330 core
    \\layout (location = 0) in vec4 aPos;
    \\layout (location = 1) in vec4 aColor;
    \\layout (location = 2) in vec2 aTexCoord;
    \\out vec2 TexCoord;
    \\out vec4 VColor;
    \\uniform mat4 model;
    \\uniform mat4 view;
    \\uniform mat4 projection;
    \\void main()
    \\{
    \\        gl_Position = projection * view * model * aPos;
    \\        TexCoord = vec2(aTexCoord.x, aTexCoord.y);
    \\        VColor = aColor;
    \\        //gl_Position = vec4(aPos, 1.0f); //test pos
    \\}
;

pub const fs: []const u8 =
    \\#version 330 core
    \\out vec4 FragColor;
    \\  
    \\in vec4 VColor; 
    \\in vec2 TexCord; 
    \\void main()
    \\{
    \\    FragColor = VColor;
    \\    //FragColor = vec4(VColor, 1.0f);
    \\} 
;

pub const ShaderInfoError = error{
    CompileError,
    ProgramLinkError,
    DebugAllocOOM,
};

pub const Shader = struct {
    programId: gl.GLuint,

    pub fn createShader(shader: []const u8, shaderKind: gl.GLenum) ShaderInfoError!gl.GLuint {
        const shaderId = gl.glCreateShader(shaderKind);

        const sourceLen: gl.GLint = @intCast(shader.len);
        gl.glShaderSource(shaderId, 1, &shader.ptr, &sourceLen);
        gl.glCompileShader(shaderId);

        var ok: gl.GLint = undefined;
        gl.glGetShaderiv(shaderId, gl.GL_COMPILE_STATUS, &ok);
        if (ok != 0) return shaderId;
        var errorSize: gl.GLint = undefined;
        gl.glGetShaderiv(shaderId, gl.GL_INFO_LOG_LENGTH, &errorSize);

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const alloc = gpa.allocator();
        if (alloc.alloc([]u8, @intCast(errorSize))) |msg| {
            const msgPtr: [*c]gl.GLchar = @ptrCast(msg);
            gl.glGetShaderInfoLog(shaderId, errorSize, &errorSize, msgPtr);
            std.debug.print("[ERROR] Shader program compile error {s}'\n", .{msg});
        } else |err| switch (err) {
            error.OutOfMemory => return ShaderInfoError.DebugAllocOOM,
        }

        return ShaderInfoError.CompileError;
    }

    pub fn checkCompileLinkError(programId: gl.GLuint) ShaderInfoError!bool {
        var ok: gl.GLint = undefined;
        gl.glGetProgramiv(programId, gl.GL_LINK_STATUS, &ok);
        if (ok != 0) return true;

        var errorSize: gl.GLint = undefined;
        gl.glGetProgramiv(programId, gl.GL_LINK_STATUS, &errorSize);

        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const alloc = gpa.allocator();
        if (alloc.alloc([]u8, @intCast(errorSize))) |msg| {
            gl.glGetProgramInfoLog(programId, errorSize, &errorSize, @ptrCast(msg));
            std.debug.print("[ERROR] Shader program link error {s}'\n", .{msg});
        } else |err| switch (err) {
            error.OutOfMemory => return ShaderInfoError.DebugAllocOOM,
        }

        return ShaderInfoError.ProgramLinkError;
    }
};
