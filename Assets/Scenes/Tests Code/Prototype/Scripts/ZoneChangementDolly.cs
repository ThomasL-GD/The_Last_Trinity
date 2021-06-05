using System;
using System.Collections;
using System.Collections.Generic;
using Cinemachine;
using UnityEngine;

public class ZoneChangementDolly : MonoBehaviour {

    [Header("")]
    [SerializeField] [Tooltip("If on, you only need to serialize the robot camera")] private bool m_isTheRobotAlone = false;
    [SerializeField] [Tooltip("If on, the camera will go back to the old camera when the character leaves the zone")] private bool m_isCancelingOnExit = false;

    [Header("Cameras")]
    //Cinemachine cameras des trois personnages zoomées sur un rail auxiliaire
    //Effectuer un blend dans la "Main Camera" avant de régler les priorités
    [SerializeField][Tooltip("Virtual Caméra Zoomée")] private CinemachineVirtualCamera m_vCamHZ = null;
    [SerializeField][Tooltip("Virtual Caméra Zoomée")] private CinemachineVirtualCamera m_vCamMZ = null;
    [SerializeField][Tooltip("Virtual Caméra Zoomée")] private CinemachineVirtualCamera m_vCamRZ = null;
    
    //Stocke l'ancienne caméra pour pouvoir y retourner quand le joueur sort de la zone
    private CinemachineVirtualCamera m_previousVCamH;
    private CinemachineVirtualCamera m_previousVCamM;
    private CinemachineVirtualCamera m_previousVCamR;

    private void Start()
    {
        if(m_vCamHZ == null && !m_isTheRobotAlone)
        {
            Debug.LogError("La camera humaine n'est pas serializée");
        }
        if(m_vCamMZ == null && !m_isTheRobotAlone)
        {
            Debug.LogError("La camera monstre n'est pas serializée");
        }
        if(m_vCamRZ == null)
        {
            Debug.LogError("La camera robot n'est pas serializée");
        }
    }

    /// <summary>
    /// Change the character's current camera to the zoomed one and stocks the old one for later
    /// </summary>
    /// <param name="p_other">Collider du joueur entrant dans la zone</param>
    private void OnTriggerEnter(Collider p_other)
    {
        if (p_other.gameObject.TryGetComponent(out PlayerController charaScript))
        {
            if(!m_isTheRobotAlone){
                switch (charaScript.m_chara)
                {
                    case Charas.Human :
                        m_previousVCamH = charaScript.GetCurrentCamera();
                        charaScript.SetNewCamera(m_vCamHZ);
                        break;
                    case Charas.Monster :
                        m_previousVCamM = charaScript.GetCurrentCamera();
                        charaScript.SetNewCamera(m_vCamMZ);
                        break;
                    case Charas.Robot :
                        m_previousVCamR = charaScript.GetCurrentCamera();
                        charaScript.SetNewCamera(m_vCamRZ);
                        //Debug.Log("New Camera set by trigger enter", this);
                        break;
                }   
            }
            else {
                m_previousVCamR = charaScript.GetCurrentCamera();
                charaScript.SetNewCamera(m_vCamRZ);
            }
            
        }
    }

    /// <summary>
    /// Puts back the previous camera to any character going out of the zone
    /// </summary>
    /// <param name="p_other">Collider du joueur entrant dans la zone</param>
    private void OnTriggerExit(Collider p_other)
    {
        if (m_isCancelingOnExit && p_other.gameObject.TryGetComponent(out PlayerController charaScript))
        {
            if(!m_isTheRobotAlone){
                switch (charaScript.m_chara)
                {
                    case Charas.Human :
                        charaScript.SetNewCamera(m_previousVCamH);
                        m_previousVCamH = m_vCamHZ;
                        break;
                    case Charas.Monster :
                        charaScript.SetNewCamera(m_previousVCamM);
                        m_previousVCamM = m_vCamMZ;
                        break;
                    case Charas.Robot :
                        charaScript.SetNewCamera(m_previousVCamR);
                        m_previousVCamR = m_vCamRZ;
                        //Debug.Log("New Camera set by trigger EXIT", this);
                        break;
                }   
            }
            else {
                charaScript.SetNewCamera(m_previousVCamR);
                m_previousVCamR = m_vCamRZ;
            }
            
        }
    }
    
}
