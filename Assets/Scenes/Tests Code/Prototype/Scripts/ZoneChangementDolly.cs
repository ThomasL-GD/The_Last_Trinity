using System;
using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class ZoneChangementDolly : MonoBehaviour
{
    [Header("Dolly")] 
    [SerializeField][Tooltip("Main Cart de Dolly")] private CinemachineSmoothPath m_mainPath;
    [SerializeField][Tooltip("Sub Cart de Dolly")] private CinemachineSmoothPath m_subPath;
    private CinemachineVirtualCamera m_virtualCamera = null;
    private CinemachineTrackedDolly m_trackedDolly = null;

    private void OnTriggerEnter(Collider p_other)
    {
        Debug.Log("Ok");
        if (p_other.gameObject.TryGetComponent(out PlayerController charaScript))
        {
            Debug.Log(charaScript.m_chara);
            switch (charaScript.m_chara)
            {
                case Charas.Human :
                    m_virtualCamera = charaScript.m_vCamH;
                    m_trackedDolly = m_virtualCamera.GetCinemachineComponent<CinemachineTrackedDolly>();
                    m_trackedDolly.m_Path = m_subPath;
                    break;
                case Charas.Monster :
                    break;
                case Charas.Robot :
                    break;
            }   
        }
    }
    
    private void OnTriggerExit(Collider p_other)
    {
        Debug.Log("Ko");
        if (p_other.gameObject.TryGetComponent(out PlayerController charaScript))
        {
            Debug.Log(charaScript.m_chara);
            switch (charaScript.m_chara)
            {
                case Charas.Human :
                    m_virtualCamera = charaScript.m_vCamH;
                    m_trackedDolly = m_virtualCamera.GetCinemachineComponent<CinemachineTrackedDolly>();
                    m_trackedDolly.m_Path = m_mainPath;
                    break;
                case Charas.Monster :
                    break;
                case Charas.Robot :
                    break;
            }   
        }
    }
    
}
