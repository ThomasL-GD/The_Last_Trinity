using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RobotUnlockingSwitch : MonoBehaviour {
    
    [SerializeField] [Tooltip("The input used to rotate chara selection clockwise")] private KeyCode m_rightInput = KeyCode.JoystickButton4;
    [SerializeField] [Tooltip("The input used to rotate chara selection counter-clockwise")] private KeyCode m_leftInput = KeyCode.JoystickButton5;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.TryGetComponent(out PlayerController playerScript)) {
            if (playerScript.m_chara == Charas.Robot) {
                
                playerScript.m_leftInput = m_leftInput;
                playerScript.m_rightInput = m_rightInput;
            }
        }
    }
}
