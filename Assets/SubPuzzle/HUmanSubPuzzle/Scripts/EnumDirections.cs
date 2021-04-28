using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Flags]
public enum Directions {
    Up = 0b0000_0001,
    Left = 0b0000_0010,
    Down = 0b0000_0100,
    Right = 0b0000_1000,
    
    None = 0b0000_0000,
}
