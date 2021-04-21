using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeathManager : MonoBehaviour {

    // WARNING ! THIS WHOLE SCRIPT WORKS ONLY WITH POSITIONS, THE VARIABLES WON'T BE CHANGED BY ANY MEAN (for now)
    [SerializeField] [Tooltip("Drop here every object that needs to be respawned correctly when one of the player dies")] private List<GameObject> m_objectsToRespawn = new List<GameObject>();
    private List<Vector3> m_saveState = new List<Vector3>();
    
    public delegate void Death();
    //This Delegator will be invoked each time  playable character dies
    public static Death DeathDelegator;

    private void Start() {
        DeathDelegator += ReplaceElements;

        for (int i = 0; i < m_objectsToRespawn.Count; i++) {
            m_saveState.Add(m_objectsToRespawn[i].transform.position);
        }
    }

    private void Update() {
        Debug.Log($"=> {m_saveState[0]}");
    }

    /// <summary>
    /// Will replace a save by a new one based on the current state of the game
    /// </summary>
    /// <param name="p_isSavingOnSaveOne">The name speaks for itself</param>
    private void AutoSave(bool p_isSavingOnSaveOne) {
        Debug.Log("Saving...");
        
        for (int i = 0; i < m_objectsToRespawn.Count; i++) {
            m_saveState[i] = m_objectsToRespawn[i].transform.position;
        }
    }
    
    /// <summary>
    /// Is used to replace every element in their original position according to the save state
    /// WARNING ! THIS WHOLE SCRIPT WORKS ONLY WITH POSITIONS, THE VARIABLES WON'T BE CHANGED BY ANY MEAN (for now)
    /// </summary>
    /// <param name="p_currentSave">The save we need to extract data from</param>
    private void ReplaceElements() {
        Debug.Log("Death");
        for (int i = 0; i < m_objectsToRespawn.Count; i++) {
            m_objectsToRespawn[i].transform.position = m_saveState[i];
        }
    }
}
