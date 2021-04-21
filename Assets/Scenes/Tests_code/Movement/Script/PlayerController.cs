using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Script du mouvement du player controller
/// Possible amelioration : Empecher l'auto-ajustement de la rotation du joueur lié au Quaternion
/// </summary>
public class PlayerController : MonoBehaviour
{

    [Flags]
    public enum Charas {
        Human = 0,
        Monster = 1,
        Robot = 2
    }

    [SerializeField] [Tooltip("Vitesse du joueur")] private float m_speed = 5f;
    [SerializeField] [Tooltip("Vitesse de Rotation du Quaternion")] private float m_rotationSpeed = 700f;
    [SerializeField] [Tooltip("The input used to select this character")] private SOInputMultiChara m_selector = null;
    [SerializeField] [Tooltip("The character whom this script is on")] private Charas m_chara = 0;
    private KeyCode[] m_keyCodes = new[] {KeyCode.Joystick1Button0, KeyCode.Joystick1Button3, KeyCode.Joystick1Button1};
    private bool m_isActive = false;

    private void Start() {
        //We create an array (because it's easier to manipulate) of all the inputs of the characters
        m_keyCodes[0] = m_selector.inputHuman;
        m_keyCodes[1] = m_selector.inputMonster;
        m_keyCodes[2] = m_selector.inputRobot;

        if (m_chara == Charas.Human) m_isActive = true;
    }

    void Update()
    {
        //The character is not able to move if not selected
        if (m_isActive) {
            float horizontalInput = Input.GetAxis("Horizontal");
            float verticalInput = Input.GetAxis("Vertical");
            
            Vector3 movementDirection = new Vector3(horizontalInput,  0, verticalInput);
            movementDirection.Normalize();
                    
            if(m_isActive) transform.Translate(movementDirection * m_speed * Time.deltaTime, Space.World);
        
            //Utilisation du Quaternion pour permettre au player de toujours se déplacer dans l'angle où il regarde
            if (movementDirection != Vector3.zero)
            {
                Quaternion toRotation = Quaternion.LookRotation(movementDirection, Vector3.up);
                        
                transform.rotation = Quaternion.RotateTowards(transform.rotation, toRotation, m_rotationSpeed * Time.deltaTime);
            }
            
        }

        //We activate this chara if its corresponding input is pressed
        if (Input.GetKeyDown(m_keyCodes[(int)m_chara])) {
            m_isActive = true;
        }
        //If any other input corresponding to a character is pressed, we inactive this chara
        else if (Input.GetKeyDown(m_keyCodes[0]) || Input.GetKeyDown(m_keyCodes[1]) || Input.GetKeyDown(m_keyCodes[2])){
            Debug.Log("whatever");
            m_isActive = false;
        }
    }
}
