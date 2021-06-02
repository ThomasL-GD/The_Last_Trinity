using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraMovement : MonoBehaviour
{
    
    private CinemachineVirtualCamera m_vCam; //Camera cinemachine
    private CinemachineTrackedDolly m_dolly; //Famille Dolly de la caméra cinemachine
    
    
    [Header("Caméra Clamp & Value")]
    
    [SerializeField] [Range(-5, 5)] [Tooltip("The max offset this camera can have on both directions")] private float m_clamp = 2.5f; //Clamp de la caméra sur le rail de dolly
    [SerializeField] [Range(0, 3)] [Tooltip("The speed at which the camera moves when the player use the appropriate input")] private float m_lookSpeed = 0f; //Vitesse de déplacement du look sur le côté
    [SerializeField] [Range(0, 6)] [Tooltip("The speed at which the camera moves when the player let go the appropriate input")] private float m_returnSpeed = 0f; //Vitesse de déplacement du retour de la caméra
    [SerializeField] [Range(-5, 5)] [Tooltip("The offset of the camera on the rail")] private float m_offsetValue = -0.5f; //Value de l'offset de la caméra sur le rail de la dolly
    private float m_globalOffset = -0.5f; //Vitesse de déplacement du retour de la caméra
    [SerializeField] [Range(0f, 1f)] private float m_incertitude = 0.1f; //Valeur d'incertitude de la distance de l'offset

    void Start()
    {
        m_vCam = gameObject.GetComponent<CinemachineVirtualCamera>();
        m_dolly = m_vCam.GetCinemachineComponent<CinemachineTrackedDolly>();
    }
    
    void Update()
    {
        //Déplacement de la caméra vers la gauche en utilisant la gachette gauche
        if (Input.GetKey(KeyCode.JoystickButton6))
        {
            if (m_offsetValue >= -m_clamp)
            {
                m_offsetValue -= m_lookSpeed * Time.deltaTime;
            } 
            else if (m_offsetValue < -m_clamp)
            {
                m_offsetValue = -m_clamp;
            }
        } else if (Input.GetKey(KeyCode.JoystickButton7))
        {
            if (m_offsetValue <= m_clamp)
            {
                m_offsetValue += m_lookSpeed * Time.deltaTime;
            } 
            else if (m_offsetValue > m_clamp)
            {
                m_offsetValue = m_clamp;
            }
        }
        //Déplacement de la caméra vers la droite en utilisant la gachette droite
        else
        {
            if (m_offsetValue != m_globalOffset && Mathf.Abs(m_offsetValue) < m_incertitude )
            {
                m_offsetValue = m_globalOffset;
            }
            else if (m_offsetValue > m_globalOffset)
            {
                m_offsetValue -= m_returnSpeed * Time.deltaTime;   
            }
            else if (m_offsetValue < m_globalOffset)
            {
                m_offsetValue += m_returnSpeed * Time.deltaTime;   
            }
        }
        m_dolly.m_AutoDolly.m_PositionOffset = m_offsetValue;
    }
}