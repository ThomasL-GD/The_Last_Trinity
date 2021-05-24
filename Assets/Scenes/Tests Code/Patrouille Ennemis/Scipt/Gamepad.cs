using System.Collections;
using System.Collections.Generic;
using System.Transactions;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Haptics;
using UnityEngine.InputSystem.XInput;
using UnityEngine.Scripting;

[Preserve]
public class Gamepad : InputDevice,IDualMotorRumble, IHaptics
{
    //private Gamepad m_gamepad = ;
    Gamepad gamepad = Gamepad.current;
    
    void Start()
    {
        var allGamepads = Gamepad.all;

        Debug.Log($"{allGamepads}");
        
    }
    // Update is called once per frame
    void Update()
    {
        // Show all gamepads in the system.
        Debug.Log(string.Join("\n", Gamepad.all));

        // Check whether the X button on the current gamepad is pressed.
        //if (Gamepad.current.xButton.wasPressedThisFrame) Debug.Log("Pressed");

        // Rumble the left motor on the current gamepad slightly.
        //Gamepad.current.SetMotorSpeeds(0.2f, 0.4f);
        

        // Look up dpad/up control on current gamepad.
        //var dpadUpControl = Gamepad.current["dpad/up"];

    }

    public void PauseHaptics()
    {
        throw new System.NotImplementedException();
    }

    public void ResumeHaptics()
    {
        throw new System.NotImplementedException();
    }

    public void ResetHaptics()
    {
        throw new System.NotImplementedException();
    }

    public void SetMotorSpeeds(float lowFrequency, float highFrequency)
    {
        throw new System.NotImplementedException();
    }
}
