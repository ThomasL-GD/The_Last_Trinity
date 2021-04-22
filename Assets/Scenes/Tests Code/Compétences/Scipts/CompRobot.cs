using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using UnityEngine;

public class CompRobot : MonoBehaviour
{
    [SerializeField] [Tooltip("The input used to select this character")] private SOInputMultiChara m_selector = null;
    private bool m_telekinesieOpen = false;
    private bool m_activeTelekinesie = false;

    private Vector3 m_originalPos;
    private Vector3 m_targetPos;
    [SerializeField] [Tooltip("The input used to select this character")] [Range(0.1f, 3f)] private float m_smoothTime = 0.3f;
    [SerializeField] [Tooltip("The input used to select this character")] [Range(1f, 30f)] private float m_teleVal = 10f;
    private Vector3 m_velocity = Vector3.zero;

    private PlayerController m_robotScript = null;
    


    void Start()
    {
        m_originalPos = transform.position;
        // Define a target position above the object transform
        m_targetPos = new Vector3(m_originalPos.x, m_originalPos.y + m_teleVal, m_originalPos.z);

        if (m_selector == null)
        {
            Debug.LogError("Manque le scriptabl object d'input");
        }    
    }

    private void Update()
    {
        if (m_telekinesieOpen)
        {
            if (Input.GetKeyDown(m_selector.inputRobot))
            {
                m_activeTelekinesie = !m_activeTelekinesie;
                if (m_activeTelekinesie) m_robotScript.m_isForbiddenToMove = true;
                Debug.Log(m_robotScript.m_isForbiddenToMove);
                if (!m_activeTelekinesie)StartCoroutine(SmoothDown());
            }
        }
        
        if (m_activeTelekinesie && m_telekinesieOpen)
        {
            // Smoothly move the object to the new position
            transform.position = Vector3.SmoothDamp(transform.position, m_targetPos, ref m_velocity, m_smoothTime);
        } else if (!m_activeTelekinesie && m_telekinesieOpen)
        {
            // Smoothly move the object to the new position
            transform.position = Vector3.SmoothDamp(transform.position, m_originalPos, ref m_velocity, m_smoothTime);
        }
    }

    IEnumerator SmoothDown()
    {
        yield return new WaitForSeconds(m_smoothTime);
        m_robotScript.m_isForbiddenToMove = false;
    }

    private void OnTriggerEnter(Collider p_other)
    {
        if (p_other.gameObject.TryGetComponent(out PlayerController player))
        {
            if (player.m_chara == Charas.Robot)
            {
                m_telekinesieOpen = true;
                m_robotScript = player;
            }
        }
    }

    private void OnTriggerExit(Collider p_other)
    {
        if (p_other.gameObject.TryGetComponent(out PlayerController player))
        {
            if (player.m_chara == Charas.Robot)
            {
                m_telekinesieOpen = false;
                m_activeTelekinesie = false;
                m_robotScript = null;
                //Debug.Log(m_telekinesieOpen);
            }
        }
    }
}
