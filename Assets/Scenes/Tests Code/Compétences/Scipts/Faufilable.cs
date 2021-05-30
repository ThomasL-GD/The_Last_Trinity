using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Faufilable : MonoBehaviour
{
    [SerializeField] [Tooltip("The input used to select this character")] private SOInputMultiChara m_selector = null;
    private bool m_isSneaky = false; //Possibilité d'activer le Faufilage avec la touche de compétence du Humain
    public bool m_isIntoWall= false; //Est en standby dans l'autre mur
    private bool m_isTeleporting= false; //Bloquage du teleport si deja un en cours


    [Header("Travel")]
    [SerializeField] [Tooltip("Time of travel between the two exits")] [Range(0.1f, 3f)] private float m_travelTime = 1f; //Temps avant que le joueur se téléporte vers la sortie
    [SerializeField] [Tooltip("The game object where the human will be sent at\n must be inside the collide boxes of another faufilable")] private GameObject m_exit = null;

    [Header("Human Properties")]
    public Transform m_human = null;
    private PlayerController m_humanScript = null;//Script de l'humain, obtenir la touche d'activation de la compétence
    private Vector3 m_travel = Vector3.zero;
    [SerializeField] [Tooltip("The speed multiplier that will be applied to the human once she's on hands and knees")] [Range(0.1f, 1f)] private float m_speedMultiplier = 0.5f;
    [SerializeField] [Tooltip("The size multiplier that will be applied to the human once she's on hands and knees")] [Range(0.1f, 1f)] private float m_sizeMultiplier = 0.3f;

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

        //During teleportation, we move the player to let the camera follow their way
        if (m_isTeleporting) {
            m_human.position += m_travel * Time.deltaTime / m_travelTime;
        }
    }

    /// <summary>
    /// Teleporte le joueur sur la sortie sérialisé
    /// </summary>
    /// <returns></returns>
    IEnumerator Teleport()
    {
        SkinnedMeshRenderer meshRenderer = m_human.gameObject.GetComponentInChildren<SkinnedMeshRenderer>();
        meshRenderer.enabled = false;
        m_humanScript.StopGravity();
        m_isTeleporting = true;
        m_travel = m_exit.transform.position - m_human.position;
        m_humanScript.m_isForbiddenToMove = true;
        //m_human.gameObject.SetActive(false);
        
        yield return new WaitForSeconds(m_travelTime);
        
        //m_human.gameObject.SetActive(true);
        m_humanScript.RestoreGravity();
        meshRenderer.enabled = true;
        Faufilable exitScript = m_exit.GetComponent<Faufilable>();
        if (exitScript.m_human == null) exitScript.m_human = m_human;
        m_human.transform.position = m_exit.transform.position;
        m_humanScript.m_isForbiddenToMove = false;
        m_isTeleporting = false;
    }
    
    /// <summary>
    /// Au contact de la zone, donne la possibilité au joueur humain (p_other) d'appuyer sur la touche de compétences
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerEnter(Collider p_other) {
        
        if (p_other.gameObject.TryGetComponent(out PlayerController player)) {
            if (player.m_chara == Charas.Human && !m_exit.GetComponent<Faufilable>().m_isIntoWall) {
                m_human = p_other.gameObject.transform;
                m_humanScript = player;
                UpdateSize(player.gameObject, true);
                player.AbilityAnim(true);
                
                m_isSneaky = true;
                m_humanScript.m_speed *= m_speedMultiplier;
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
                UpdateSize(player.gameObject, false);
                RemoveSneakiness();
            }
        }
    }

    /// <summary>
    /// Is used to replace the size of the human's collider and charaController
    /// </summary>
    /// <param name="p_player">The game object of the chara to update size of</param>
    /// <param name="p_isShrinking">if on, their collider will shrink, else, it will grow back</param>
    private void UpdateSize(GameObject p_player, bool p_isShrinking) {
        float sizeMultiplier = m_sizeMultiplier;
        //If we wanna grow instead of shrink, we just revert the multiplier
        if (!p_isShrinking) {
            sizeMultiplier = 1 / m_sizeMultiplier;
        }
        
        //Capsule collider size update
        CapsuleCollider capsule = p_player.GetComponent<CapsuleCollider>();
        capsule.height *= sizeMultiplier;
        capsule.center *= sizeMultiplier;
        
        //CharaController size update
        CharacterController charaController = p_player.GetComponent<CharacterController>();
        charaController.height *= sizeMultiplier;
        charaController.center *= sizeMultiplier;

    }

    /// <summary>
    /// Will remove the sneaky effect on the human and reset a few values
    /// </summary>
    private void RemoveSneakiness() {
        if(!m_isTeleporting) m_humanScript.AbilityAnim(false);
        m_isSneaky = false;
        m_humanScript.m_speed /= m_speedMultiplier;
    }
}
