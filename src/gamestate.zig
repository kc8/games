pub const GameState = struct {
    isExit: bool = false,
    isForward: bool, 
    isBackwards: bool = false,
    isLeft: bool = false,
    isRight: bool = false,

    const Self = @This();
};

pub const input = struct {
};
