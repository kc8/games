const gl = @cImport({
    @cInclude("glfw3.h");
    @cInclude("gl3.h");
});
const VF4 = @import("math/vector.zig").VF4;

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

//............... OPENGL RECT ...............................////////////
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
    gl.glBufferData(
        gl.GL_ARRAY_BUFFER,
        @intCast(rectVerts.len * @sizeOf(gl.GLfloat)),
        rectVerts,
        gl.GL_STATIC_DRAW,
    );

    gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, ebo);
    gl.glBufferData(
        gl.GL_ELEMENT_ARRAY_BUFFER,
        @intCast(rectIndices.len * @sizeOf(u32)),
        rectIndices,
        gl.GL_STATIC_DRAW,
    );

    // pos cords
    gl.glVertexAttribPointer(
        0,
        4,
        gl.GL_FLOAT,
        gl.GL_FALSE,
        10 * @sizeOf(gl.GLfloat),
        null,
    );
    gl.glEnableVertexAttribArray(0);
    // colors
    gl.glVertexAttribPointer(
        1,
        4,
        gl.GL_FLOAT,
        gl.GL_FALSE,
        10 * @sizeOf(gl.GLfloat),
        @ptrFromInt((4 * @sizeOf(gl.GLfloat))),
    );
    gl.glEnableVertexAttribArray(1);
    // texture coord attribute
    gl.glVertexAttribPointer(
        2,
        2,
        gl.GL_FLOAT,
        gl.GL_FALSE,
        10 * @sizeOf(gl.GLfloat),
        @ptrFromInt((8 * @sizeOf(gl.GLfloat))),
    );
    gl.glEnableVertexAttribArray(2);
    return .{
        .vao = vao,
        .vbo = vbo,
        .ebo = ebo,
    };
}

//............... OPENGL CUBE ...............................////////////
const cubeVerts = &[_]gl.GLfloat{
    //  Positions          // Colors           // tex Coords

    -1.0, -1.0, 1.0,  1.0, 1.0, 1.0, 0.0, 0.0,
    1.0,  -1.0, 1.0,  1.0, 1.0, 1.0, 0.0, 0.0,
    1.0,  1.0,  1.0,  1.0, 1.0, 1.0, 0.0, 0.0,
    -1.0, 1.0,  1.0,  1.0, 1.0, 1.0, 0.0, 0.0,

    -1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 0.0, 0.0,
    1.0,  -1.0, -1.0, 1.0, 1.0, 1.0, 0.0, 0.0,
    1.0,  1.0,  -1.0, 1.0, 1.0, 1.0, 0.0, 0.0,
    -1.0, 1.0,  -1.0, 1.0, 1.0, 1.0, 0.0, 0.0,
};

const cubeIndices = &[_]u32{
    // front
    0, 1, 2,
    2, 3, 0,
    // right
    1, 5, 6,
    6, 2, 1,
    // back
    7, 6, 5,
    5, 4, 7,
    // left
    4, 0, 3,
    3, 7, 4,
    // bottom
    4, 5, 1,
    1, 0, 4,
    // top
    3, 2, 6,
    6, 7, 3,
};

fn generateCube(c: VF4) [64]gl.GLfloat {
    const result = [_]gl.GLfloat{
        //  Positions          // Colors           // tex Coords
        // Front
        -0.5, -0.5, 0.5,  c.x, c.y, c.z, c.w, 1.0, 0.0, 0.0,
        0.5,  -0.5, 0.5,  1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0,
        0.5,  0.5,  0.5,  1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0,
        -0.5, 0.5,  0.5,  1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0,
        // Back
        -0.5, -0.5, -0.5, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0,
        0.5,  -0.5, -0.5, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0,
        0.5,  0.5,  -0.5, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0,
        -0.5, 0.5,  -0.5, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0,
        // Left
        -0.5, 0.5,  0.5,  1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0,
        -0.5, 0.5,  -0.5, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0,
        -0.5, -0.5, -0.5, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0,
        -0.5, -0.5, 0.5,  1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0,
        // Right
        0.5,  0.5,  0.5,  1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0,
        0.5,  0.5,  -0.5, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0,
        0.5,  -0.5, -0.5, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0,
        0.5,  -0.5, 0.5,  1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0,
        // Top
        -0.5, 0.5,  -0.5, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0,
        0.5,  0.5,  -0.5, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0,
        0.5,  0.5,  0.5,  1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0,
        -0.5, 0.5,  0.5,  1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0,
        // Bottom
        -0.5, -0.5, -0.5, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0,
        0.5,  -0.5, -0.5, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0,
        0.5,  -0.5, 0.5,  1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0,
        -0.5, -0.5, 0.5,  1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0,
    };
    _ = result;
    const newCube = [_]gl.GLfloat{
        //  Positions          // Colors           // tex Coords

        -1.0, -1.0, 1.0,  0.0, 0.0, 1.0, 0.0, 0.0,
        1.0,  -1.0, 1.0,  1.0, 1.0, 0.0, 0.0, 0.0,
        1.0,  1.0,  1.0,  1.0, 1.0, 0.0, 0.0, 0.0,
        -1.0, 1.0,  1.0,  0.0, 0.0, 1.0, 0.0, 0.0,

        -1.0, -1.0, -1.0, 1.0, 1.0, 0.0, 0.0, 0.0,
        1.0,  -1.0, -1.0, 1.0, 1.0, 0.0, 0.0, 0.0,
        1.0,  1.0,  -1.0, 1.0, 1.0, 0.0, 0.0, 0.0,
        -1.0, 1.0,  -1.0, 1.0, 1.0, 0.0, 0.0, 0.0,
    };
    return newCube;
}

pub fn getCubeRenderCount() u32 {
    return cubeIndices.len;
}

pub fn generateOpenglCube() RenderProperties.OpenglProps {
    var vao: gl.GLuint = undefined;
    var vbo: gl.GLuint = undefined;
    var ebo: gl.GLuint = undefined;

    // We can do many buffers at once
    gl.glGenVertexArrays(1, &vao);
    gl.glGenBuffers(1, &vbo);
    gl.glGenBuffers(1, &ebo);

    const colorCube = generateCube(.{
        .x = 1.0,
        .y = 1.0,
        .z = 1.0,
        .w = 1.0,
    });
    gl.glBindVertexArray(vao);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, vbo);
    gl.glBufferData(
        gl.GL_ARRAY_BUFFER,
        @intCast(colorCube.len * @sizeOf(gl.GLfloat)),
        &colorCube,
        //cubeVerts,
        gl.GL_STATIC_DRAW,
    );

    gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, ebo);
    gl.glBufferData(
        gl.GL_ELEMENT_ARRAY_BUFFER,
        @intCast(cubeIndices.len * @sizeOf(u32)),
        cubeIndices,
        gl.GL_STATIC_DRAW,
    );

    // pos cords
    gl.glVertexAttribPointer(
        0,
        3,
        gl.GL_FLOAT,
        gl.GL_FALSE,
        8 * @sizeOf(gl.GLfloat),
        null,
    );
    gl.glEnableVertexAttribArray(0);
    // colors
    gl.glVertexAttribPointer(
        1,
        3,
        gl.GL_FLOAT,
        gl.GL_FALSE,
        8 * @sizeOf(gl.GLfloat),
        @ptrFromInt((4 * @sizeOf(gl.GLfloat))),
    );
    gl.glEnableVertexAttribArray(1);
    // texture coord attribute
    gl.glVertexAttribPointer(
        2,
        2,
        gl.GL_FLOAT,
        gl.GL_FALSE,
        8 * @sizeOf(gl.GLfloat),
        @ptrFromInt((8 * @sizeOf(gl.GLfloat))),
    );
    gl.glEnableVertexAttribArray(2);
    return .{
        .vao = vao,
        .vbo = vbo,
        .ebo = ebo,
    };
}
