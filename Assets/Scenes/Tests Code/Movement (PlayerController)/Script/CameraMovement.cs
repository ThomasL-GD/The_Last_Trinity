using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraMovement : MonoBehaviour
{
    //Keycode des deux gachettes gauche et droite
    private KeyCode[] m_keyCodes = new[] {KeyCode.Joystick1Button6, KeyCode.Joystick1Button7};
    
    private CinemachineVirtualCamera m_vCam; //Camera cinemachine
    private CinemachineTrackedDolly m_dolly; //Famille Dolly de la caméra cinemachine
    private float m_offsetValue = 0f;
    
    [SerializeField] [Range(-5, 5)]private float m_clamp = 2.5f; //Clamp de la caméra sur le rail de dolly
    [SerializeField] [Range(0, 3)] private float m_lookSpeed = 0f; //Vitesse de déplacement du look sur le côté
    [SerializeField] [Range(0, 6)] private float m_returnSpeed = 0f; //Vitesse de déplacement du retour de la caméra
    private float m_incertitude = 0.1f; //Valeur d'incertitude de la distance de l'offset

    void Start()
    {
        m_vCam = gameObject.GetComponent<CinemachineVirtualCamera>();
        m_dolly = m_vCam.GetCinemachineComponent<CinemachineTrackedDolly>();
    }
    
    void Update()
    {
        //Déplacement de la caméra vers la gauche par la gachette de gauche
        if (Input.GetKey(m_keyCodes[0]))
        {
            if (m_offsetValue >= -m_clamp)
            {
                m_offsetValue -= m_lookSpeed * Time.deltaTime;
            } else if (m_offsetValue < -m_clamp)
            {
                m_offsetValue = -m_clamp;
            }
        } else if (Input.GetKey(m_keyCodes[1]))
        {
            if (m_offsetValue <= m_clamp)
            {
                m_offsetValue += m_lookSpeed * Time.deltaTime;
            } else if (m_offsetValue > m_clamp)
            {
                m_offsetValue = m_clamp;
            }
        }
        //Déplacement de la caméra vers la droite par la gachette de droite
        else
        {
            if (m_offsetValue != 0f && Mathf.Abs(m_offsetValue) < m_incertitude )
            {
                m_offsetValue = 0f;
            }
            else if (m_offsetValue > 0f)
            {
                m_offsetValue -= m_returnSpeed * Time.deltaTime;   
            }
            else if (m_offsetValue < 0f)
            {
                m_offsetValue += m_returnSpeed * Time.deltaTime;   
            }
        }
        m_dolly.m_AutoDolly.m_PositionOffset = m_offsetValue;
    }
}
