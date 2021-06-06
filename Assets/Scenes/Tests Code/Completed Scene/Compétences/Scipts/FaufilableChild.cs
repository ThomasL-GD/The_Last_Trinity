using UnityEngine;

public class FaufilableChild : MonoBehaviour {

    [HideInInspector] public Faufilable m_parentScript = null; //The script of the parent

    // Start is called before the first frame update
    void Start() {
        m_parentScript = GetComponentInParent<Faufilable>();
        if(m_parentScript == null) Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THIS SCRIPT IN A GAMEOBJECT CHILD OF A FAUFILABLE OBJECT !");
    }

    /// <summary>
    /// Is called when an object enters this trigger zone,
    /// Will tell its parent that the player is in the wall if it occurs
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerEnter(Collider p_other) {
        if (p_other.gameObject.transform == m_parentScript.m_human) {
            m_parentScript.m_isIntoWall = true;
            if(m_parentScript.m_teleportFeedback != null) m_parentScript.m_teleportFeedback.SetActive(true);
        }
    }
    
    /// <summary>
    /// Is called when an object exits this trigger zone,
    /// Will tell its parent that the player is no longer in the wall if it occurs
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerExit(Collider p_other) {
        if (p_other.gameObject.transform == m_parentScript.m_human) {
            m_parentScript.m_isIntoWall = false;
            if(m_parentScript.m_teleportFeedback != null) m_parentScript.m_teleportFeedback.SetActive(false);
        }
    }
}
