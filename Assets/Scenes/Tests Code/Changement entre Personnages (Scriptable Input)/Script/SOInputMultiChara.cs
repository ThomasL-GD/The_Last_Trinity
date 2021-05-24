using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using System.Linq;
using UnityEngine.InputSystem.Controls;
using UnityEngine.InputSystem.DualShock;
using UnityEngine.InputSystem.HID;

[CreateAssetMenu(fileName = "InputMultiChara", menuName = "Inputs/InputMultiChara", order = 1)]
public class SOInputMultiChara : ScriptableObject {
    
    //Déplacement hors subpuzzle
    [SerializeField] public KeyCode inputHuman = KeyCode.Joystick1Button0;
    [SerializeField] public KeyCode inputMonster = KeyCode.Joystick1Button3;
    [SerializeField] public KeyCode inputRobot = KeyCode.Joystick1Button1;
    
    //[SerializeField] public bool newInputHuman = m_gamepad.buttonWest.isPressed;
    //[SerializeField] public ButtonControl newInputMonster = Gamepad.current.buttonNorth;
    //[SerializeField] public bool newInputRobot = m_gamepad.buttonEast.isPressed;
}