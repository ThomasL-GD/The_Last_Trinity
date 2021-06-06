using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OldDeathManager : MonoBehaviour {

    // WARNING ! THIS WHOLE SCRIPT WORKS ONLY WITH POSITIONS, THE VARIABLES WON'T BE CHANGED BY ANY MEAN (for now)
    [SerializeField] [Tooltip("Drop here every object that needs to be respawned correctly when one of the player dies")] private List<GameObject> m_objectsToRespawn = new List<GameObject>();
    [SerializeField] [Tooltip("The time between each autosave (unit : seconds)")] private float m_autoSaveDelay = 5.0f;
    private List<Vector3> m_saveOne = new List<Vector3>();
    private List<Vector3> m_saveTwo = new List<Vector3>();
    private bool m_isSaveOne = false;
    private bool m_isAutoSaving = true;
    
    public delegate void Death();
    //This Delegator will be invoked each time  playable character dies
    public static Death DeathDelegator;

    private void Start() {
        DeathDelegator += ReplaceElements;

        for (int i = 0; i < m_objectsToRespawn.Count; i++) {
            m_saveOne.Add(m_objectsToRespawn[i].transform.position);
            m_saveTwo.Add(m_objectsToRespawn[i].transform.position);
        }
        
        StartCoroutine(AutoSaveTimer());
        
        Debug.LogWarning("THIS SCRIPT IS OLD AND MAY NOT WORK, PLEASE STOP USING IT WITHOUT PERMISSION OR I'LL COME TO YOUR HOUSE WITH MY HOLY CHAINSAW");
    }
    
    /// Do I really have to explain this ?
    IEnumerator AutoSaveTimer() {
        //Eventually, we're gonna replace the stupid "m_isAutoSaving" by something smart
        while (m_isAutoSaving) {
            yield return new WaitForSeconds(m_autoSaveDelay);
            AutoSave(m_isSaveOne);
        }
    }

    private void Update() {
        Debug.Log($"=> {m_saveOne[0]}");
    }

    /// <summary>
    /// Will replace a save by a new one based on the current state of the game
    /// </summary>
    /// <param name="p_isSavingOnSaveOne">The name speaks for itself</param>
    private void AutoSave(bool p_isSavingOnSaveOne) {
        Debug.Log("AutoSave");
        if (p_isSavingOnSaveOne) {
            for (int i = 0; i < m_objectsToRespawn.Count; i++) {
                m_saveOne[i] = m_objectsToRespawn[i].transform.position;
            }

            m_isSaveOne = false;
        }
        else {
            for (int i = 0; i < m_objectsToRespawn.Count; i++) {
                m_saveTwo[i] = m_objectsToRespawn[i].transform.position;
            }

            m_isSaveOne = true;
        }
    }
    
    
    
    /// <summary>
    /// Is used to call ReplaceElementsSave with the appropriate save
    /// </summary>
    private void ReplaceElements() {
        // if (m_isSaveOne) {
        //     ReplaceElementsSave(m_saveOne);
        // }
        // else {
        //     ReplaceElementsSave(m_saveTwo);
        // }
        //The line below means the lines above and dang it that's freaking shorter
        ReplaceElementsSave(m_isSaveOne ? m_saveOne : m_saveTwo);
        
    }
    
    /// <summary>
    /// Is used to replace every element in their original position according to the save
    /// WARNING ! THIS WHOLE SCRIPT WORKS ONLY WITH POSITIONS, THE VARIABLES WON'T BE CHANGED BY ANY MEAN (for now)
    /// </summary>
    /// <param name="p_currentSave">The save we need to extract data from</param>
    private void ReplaceElementsSave(List<Vector3> p_currentSave) {
        Debug.Log("Death");
        for (int i = 0; i < m_objectsToRespawn.Count; i++) {
            m_objectsToRespawn[i].transform.position = p_currentSave[i];
        }
    }
}
