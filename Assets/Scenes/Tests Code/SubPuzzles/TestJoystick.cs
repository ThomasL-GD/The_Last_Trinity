using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestJoystick : MonoBehaviour
{

    [Tooltip("position limite de joystick à gauche")] private float m_limitPosition = 0.5f;

    [SerializeField] [Tooltip("variable de déplacement en points par points")] private bool m_hasMoved = false;
    
    private void Update()
    {
        float horizontalAxis = Input.GetAxis("Horizontal");
        float verticalAxis = Input.GetAxis("Vertical");
         
        foreach(KeyCode kcode in Enum.GetValues(typeof(KeyCode)))
        {
            if (Input.GetKey(kcode))
                Debug.Log("KeyCode down: " + kcode);
        }

        
        if (horizontalAxis < -m_limitPosition && !m_hasMoved)
        {
            Debug.Log("déplacement à gauche");
            m_hasMoved = true;
        }
        else if (horizontalAxis > m_limitPosition && !m_hasMoved)
        {
            Debug.Log("déplacement à droite");
            m_hasMoved = true;
        }
        else if (verticalAxis >m_limitPosition && !m_hasMoved)
        {
            Debug.Log("déplacement en haut");
            m_hasMoved = true;
        }
        else if (verticalAxis < -m_limitPosition && !m_hasMoved)
        {
            Debug.Log("déplacement en bas");
            m_hasMoved = true;
        }
        else if (horizontalAxis < m_limitPosition && horizontalAxis > -m_limitPosition && verticalAxis < m_limitPosition && verticalAxis > -m_limitPosition)
        {
            m_hasMoved = false;
        }
    }
    
}
