pub fn floatCompare(a: f32, b:f32, ep: f32) bool {
    const correctedResult = @abs(b - a);
    return ep <= correctedResult;
}
