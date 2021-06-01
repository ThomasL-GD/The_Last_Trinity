using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OLD_Checkpoint : MonoBehaviour {

    [SerializeField] [Tooltip("The characters who need to get to this checkpoint in order to activate it, SELECT ONLY ONE PER CASE IN THE LIST\nIf you want it to be activated once any character comes in, let the list empty")] private List<Charas> m_CharasNeeded = new List<Charas>();
    private List<Charas> m_CharasStillInNeed = new List<Charas>(); /*Stocks the characters who did not validate the checkpoint YET, we remove them from the list once they validate it*/

    [SerializeField] [Tooltip("When the playable characters will respawn, they have to be offsetted from each other (unit : meters)\nMUST NOT BE LESS THAN THE THICKNESS OF ANY PLAYABLE CHARACTER")] private float m_offset = 1.0f;
    
    private void Start() {
        m_CharasStillInNeed = m_CharasNeeded;

        if (!gameObject.TryGetComponent(out BoxCollider bCol)) {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT A BOX COLLIDER ON A CHECKPOINT ! WHAT A DUMBA$$ !");
        }
        else if (!gameObject.GetComponent<BoxCollider>().isTrigger) {
            Debug.LogError("JEEZ ! THE GAME DESIGNER FORGOT TO PUT THE BOX COLLIDER IN TRIGGER MODE ! IS HE THAT STUPID ?!");
        }
    }

    /// <summary>
    /// Is called when this object triggers with another one.
    /// </summary>
    /// <param name="p_other">The Collider of the object we're triggering with</param>
    private void OnTriggerEnter(Collider p_other) {
        //We verify if the object we're colliding with is a playable character
        if (p_other.gameObject.TryGetComponent(out PlayerController pScript)) {
            //In case we needed this character to validate, we do.
            for (int i = 0; i < m_CharasStillInNeed.Count; i++) {
                if (m_CharasStillInNeed[i] == pScript.m_chara) {
                    m_CharasNeeded.RemoveAt(i);
                }
            }

            //If we already validated all the characters we needed, we define this checkpoint as the active one (cf. DeathManager for more info on how we actually do this)
            if (m_CharasStillInNeed.Count == 0) {
                float offset = 0.0f;
                for (int i = 0; i < DeathManager.Instance.m_objectsToRespawn.Count; i++) {
                    if (DeathManager.Instance.m_objectsToRespawn[i].TryGetComponent(out PlayerController pScriptInArray)) {
                        DeathManager.Instance.m_saveState[i] = new Vector3(transform.position.x, transform.position.y + 0.05f, transform.position.z + offset);
                        offset += m_offset;
                    }
                }
            }
        }
    }
}