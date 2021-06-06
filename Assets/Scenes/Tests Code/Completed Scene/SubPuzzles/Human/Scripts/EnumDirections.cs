using System;

/// <summary>
/// This enum that can stocks directions, as it is a bitmask enum, it can stock multiples directions at once
/// </summary>
[Flags]
public enum Directions {
    Up = 0b0000_0001,
    Left = 0b0000_0010,
    Down = 0b0000_0100,
    Right = 0b0000_1000,
    
    None = 0b0000_0000,
    All = 0b0000_1111,
}
