const gl = @cImport({
    @cInclude("glfw3.h");
    @cInclude("gl3.h");
});

pub const RenderProperties = struct {
    elementRenderCount: u32,
    openGlProps: OpenglProps,
    programId: u32, // also shader id

    pub const OpenglProps = struct {
        vao: gl.GLuint = undefined,
        vbo: gl.GLuint = undefined,
        ebo: gl.GLuint = undefined,

        // defer deleteMe(RenderProperties.OpenglProps);
        pub fn deferMe(self: OpenglProps) void {
            gl.glDeleteVertexArrays(1, self.vao);
            gl.glDeleteBuffers(1, self.vbo);
        }
    };
};

const rectVerts = &[_]gl.GLfloat{
    // positions        // colors     // texture coords
    0.5, 0.5, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, // top right
    0.5, -0.5, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, // bottom right
    -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, // bottom left
    -0.5, 0.5, 0.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, // top left
};

const rectIndices = &[_]u32{ 0, 1, 3, 1, 2, 3 };

pub fn getRectRenderCount() u32 {
    return rectIndices.len;
}

// float only
pub fn generateOpenglRect() RenderProperties.OpenglProps {
    var vao: gl.GLuint = undefined;
    var vbo: gl.GLuint = undefined;
    var ebo: gl.GLuint = undefined;

    // We can do many buffers at once
    gl.glGenVertexArrays(1, &vao);
    gl.glGenBuffers(1, &vbo);
    gl.glGenBuffers(1, &ebo);

    gl.glBindVertexArray(vao);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @intCast(rectVerts.len * @sizeOf(gl.GLfloat)), rectVerts, gl.GL_STATIC_DRAW);

    gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, ebo);
    gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, @intCast(rectIndices.len * @sizeOf(u32)), rectIndices, gl.GL_STATIC_DRAW);

    // pos cords
    gl.glVertexAttribPointer(0, 4, gl.GL_FLOAT, gl.GL_FALSE, 10 * @sizeOf(gl.GLfloat), null);
    gl.glEnableVertexAttribArray(0);
    // colors
    gl.glVertexAttribPointer(1, 4, gl.GL_FLOAT, gl.GL_FALSE, 10 * @sizeOf(gl.GLfloat), @ptrFromInt((4 * @sizeOf(gl.GLfloat))));
    gl.glEnableVertexAttribArray(1);
    // texture coord attribute
    gl.glVertexAttribPointer(2, 2, gl.GL_FLOAT, gl.GL_FALSE, 10 * @sizeOf(gl.GLfloat), @ptrFromInt((8 * @sizeOf(gl.GLfloat))));
    gl.glEnableVertexAttribArray(2);
    return .{
        .vao = vao, 
        .vbo = vbo, 
        .ebo = ebo,
    };
}
