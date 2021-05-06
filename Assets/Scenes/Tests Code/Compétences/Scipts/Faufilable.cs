using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Faufilable : MonoBehaviour
{
    [SerializeField] [Tooltip("The input used to select this character")] private SOInputMultiChara m_selector = null;
    private bool m_isOpenToFaufilage = false; //Possibilité d'activer le Faufilage avec la touche de compétence du Humain
    private bool m_isIntoWall= false; //Est en standby dans l'autre mur
    
    [SerializeField] private Transform m_exit = null;

    [Header("Travel Timing")]
    [SerializeField] [Tooltip("Time of animation")] [Range(0.1f, 3f)] private float m_animTime = 1f; //Temps pour l'éxécution de l'animation de faufilage
    [SerializeField] [Tooltip("Time of travel between the two exits")] [Range(0.1f, 3f)] private float m_travelTime = 1f; //Temps avant que le joueur se téléporte vers la sortie
    [SerializeField] [Tooltip("Offset for getting out of the exit")] [Range(0.1f, 3f)] private float m_offset = 0.2f; //Offset du joueur pour le placer dans la fissure

    [SerializeField] [Tooltip("For Debug Only")] private Transform m_human = null;
    [SerializeField] [Tooltip("For Debug Only")] private PlayerController m_humanScript = null;//Script de l'humain, obtenir la touche d'activation de la compétence

    void Start()
    {
        if (m_selector == null)
        {
            Debug.LogError("Manque le scriptable object d'input");
        }

        if (m_exit == null)
        {
            Debug.LogError("Le Transform n'est pas sérialisé");
        }
    }

    private void Update()
    {
        if (m_isOpenToFaufilage)
        { ;
            if (!m_isIntoWall && m_humanScript.m_isActive && Input.GetKeyDown(m_selector.inputHuman))
            {
                Debug.Log("Begin");
                m_humanScript.m_isForbiddenToMove = true;
                StartCoroutine(AnimationEntree());
            }
        }

        if (m_isIntoWall && Input.GetKeyDown(m_selector.inputHuman))
        {
            StartCoroutine(AnimationSortie());
        }
    }

    /// <summary>
    /// Laisse le temps à l'animation de se jouer pour passer dans le mur
    /// </summary>
    /// <returns></returns>
    IEnumerator AnimationEntree()
    {
        Debug.Log("Animation Enter");
        //Animation Play()
        yield return new WaitForSeconds(m_animTime);
        StartCoroutine(Teleport());
    }

    /// <summary>
    /// Teleporte le joueur sur la sortie sérialisé
    /// </summary>
    /// <returns></returns>
    IEnumerator Teleport()
    {
        Debug.Log("Teleport");
        yield return new WaitForSeconds(m_travelTime);
        m_human.transform.position = m_exit.transform.position;
        m_isIntoWall = true;
    }
    
    /// <summary>
    /// Laisse le temps à l'animation de se jouer pour sortir du mur
    /// </summary>
    /// <returns></returns>
    IEnumerator AnimationSortie()
    {
        Debug.Log("Animation Sortie");
        //Animation Play()
        yield return new WaitForSeconds(m_animTime);
        m_humanScript.m_isForbiddenToMove = false;
        m_isIntoWall = false;
        
        //Reset des valeurs
        m_human = null;
        m_humanScript = null;
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
                m_isOpenToFaufilage = true;
                m_human = p_other.gameObject.transform;
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
            Debug.Log("Prout");
            if (player.m_chara == Charas.Human)
            {
                m_isOpenToFaufilage = false;
                //Debug.Log(m_telekinesieOpen);
            }
        }
    }
}
