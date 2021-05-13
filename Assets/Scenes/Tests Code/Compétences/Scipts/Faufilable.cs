using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Faufilable : MonoBehaviour
{
    [SerializeField] [Tooltip("The input used to select this character")] private SOInputMultiChara m_selector = null;
    [SerializeField] [Tooltip("For Debug Only")] private bool m_isSneaky = false; //Possibilité d'activer le Faufilage avec la touche de compétence du Humain
    [SerializeField] [Tooltip("For Debug Only")] public bool m_isIntoWall= false; //Est en standby dans l'autre mur
    [SerializeField] [Tooltip("For Debug Only")] private bool m_isTeleporting= false; //Bloquage du teleport si deja un en cours

    [SerializeField] private GameObject m_exit = null;

    [Header("Travel")]
    [SerializeField] [Tooltip("Time of travel between the two exits")] [Range(0.1f, 3f)] private float m_travelTime = 1f; //Temps avant que le joueur se téléporte vers la sortie

    [SerializeField] [Tooltip("For Debug Only")] public Transform m_human = null;
    [SerializeField] [Tooltip("For Debug Only")] private PlayerController m_humanScript = null;//Script de l'humain, obtenir la touche d'activation de la compétence

    void Start()
    {
        if (m_selector == null) {
            Debug.LogError("Manque le scriptable object d'input");
        }

        if (m_exit == null) {
            Debug.LogError("Le Transform n'est pas sérialisé");
        }
    }

    private void Update() {

        if (!m_isTeleporting && m_isIntoWall && Input.GetKeyDown(m_selector.inputHuman)) {
            StartCoroutine(Teleport());
        }
    }

    /// <summary>
    /// Teleporte le joueur sur la sortie sérialisé
    /// </summary>
    /// <returns></returns>
    IEnumerator Teleport() {
        m_isTeleporting = true;
        m_humanScript.m_isForbiddenToMove = true;
        
        yield return new WaitForSeconds(m_travelTime);
        
        Faufilable exitScript = m_exit.GetComponent<Faufilable>();
        if (exitScript.m_human == null) exitScript.m_human = m_human;
        m_human.transform.position = m_exit.transform.position;
        m_humanScript.m_isForbiddenToMove = false;
        m_isTeleporting = false;
        //RemoveSneakiness();
    }
    
    /// <summary>
    /// Au contact de la zone, donne la possibilité au joueur humain (p_other) d'appuyer sur la touche de compétences
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerEnter(Collider p_other) {
        
        if (p_other.gameObject.TryGetComponent(out PlayerController player)) {
            if (player.m_chara == Charas.Human && !m_exit.GetComponent<Faufilable>().m_isIntoWall) {
                m_isSneaky = true;
                m_human = p_other.gameObject.transform;
                m_humanScript = player;
                m_humanScript.m_speed /= 2;
            }
        }
    }

    /// <summary>
    /// A la sortie de la zone, désactiver les booleens
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerExit(Collider p_other)
    {
        if (p_other.gameObject.TryGetComponent(out PlayerController player)) {
            if (player.m_chara == Charas.Human) {
                RemoveSneakiness();
            }
        }
    }

    /// <summary>
    /// Will remove the sneaky effect on the human and reset a few values
    /// </summary>
    private void RemoveSneakiness() {
        m_isSneaky = false;
        m_humanScript.m_speed *= 2;
    }
}
