using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Faufilable : MonoBehaviour
{
    [SerializeField] [Tooltip("The input used to select this character")] private SOInputMultiChara m_selector = null;
    private bool m_faufilableOpen = false; //Possibilité d'activer le Faufilage avec la touche de compétence du Humain
    private bool m_activeFaufilage = false;
    private bool m_isHidden = false;

    private Vector3 m_originalPos;
    private Vector3 m_targetPos;
    [SerializeField] [Tooltip("Time of Travel")] [Range(0.1f, 3f)] private float m_smoothTime = 1f;
    [SerializeField] [Tooltip("Height of Travel")] [Range(1f, 30f)] private float m_teleVal = 10f;
    
    [SerializeField] [Tooltip("Un slider d'int")] [Range(0, 4)] private int m_unSliderDint = 2;
    //[SerializeField] [Tooltip("The maximum authorized difference between the position to reach and the current position (unit : Unity meters)")] [Range(0f, 1f)] private float m_uncertainty = 0.1f;
    private Vector3 m_velocity = Vector3.zero;

    private PlayerController m_humanScript = null;
    


    void Start()
    {
        m_originalPos = transform.position;
        // Define a target position above the object transform
        m_targetPos = new Vector3(m_originalPos.x, m_originalPos.y + m_teleVal, m_originalPos.z);

        if (m_selector == null)
        {
            Debug.LogError("Manque le scriptable object d'input");
        }    
    }

    private void Update()
    {
        Vector3 posClamp = ClampEnjoyer(transform.position);
        
        if (m_faufilableOpen)
        {
            if (Input.GetKeyDown(m_selector.inputRobot) && !m_isHidden && m_humanScript.m_isActive)
            {
                m_isHidden = true;
                if (m_activeFaufilage) m_humanScript.m_isForbiddenToMove = true;
            }
        }
    }

    /// <summary>
    /// Au contact de la zone, donne la possibilité au joueur humain (p_other) d'appuyer sur la touche de compétences
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerEnter(Collider p_other)
    {
        if (p_other.gameObject.TryGetComponent(out PlayerController player))
        {
            if (player.m_chara == Charas.Human)
            {
                m_faufilableOpen = true;
                m_humanScript = player;
            }
        }
    }

    /// <summary>
    /// A la sortie de la zone, désactiver les booleens
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerExit(Collider p_other)
    {
        if (p_other.gameObject.TryGetComponent(out PlayerController player))
        {
            if (player.m_chara == Charas.Robot)
            {
                m_faufilableOpen = false;
                m_activeFaufilage = false;
                m_humanScript = null;
                //Debug.Log(m_telekinesieOpen);
            }
        }
    }

    private Vector3 ClampEnjoyer(Vector3 p_pos)
    {
        float pow = Mathf.Pow(10, m_unSliderDint);
        return new Vector3(Mathf.Round((p_pos.x * pow)/pow), Mathf.Round((p_pos.y * pow)/pow), Mathf.Round((p_pos.z * pow)/pow));
    }
}
