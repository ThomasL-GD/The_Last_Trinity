using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraMovement : MonoBehaviour
{
    private KeyCode[] m_keyCodes = new[] {KeyCode.Joystick1Button6, KeyCode.Joystick1Button7};
    
    private CinemachineVirtualCamera m_vCam;
    private CinemachineTrackedDolly m_dolly;
    
    void Start()
    {
        m_vCam = gameObject.GetComponent<CinemachineVirtualCamera>();
        m_dolly = m_vCam.GetCinemachineComponent<CinemachineTrackedDolly>();
    }
    
    void Update()
    {
        if (Input.GetKey(m_keyCodes[0]))
        {
            Debug.Log("Left");
            m_dolly.m_AutoDolly.m_PositionOffset--;
        } else if (Input.GetKey(m_keyCodes[1]))
        {
            Debug.Log("Right");
            m_dolly.m_AutoDolly.m_PositionOffset++;
        }
        else
        {
            m_dolly.m_AutoDolly.m_PositionOffset = 0;
        }
    }
}
