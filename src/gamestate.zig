pub const GameState = struct {
    isExit: bool = false,
    isForward: bool,
    isBackwards: bool = false,
    isLeft: bool = false,
    isRight: bool = false,
    quit: bool = false,
    windowHeight: i32,
    windowWidth: i32,

    const Self = @This();
};

pub const input = struct {};
