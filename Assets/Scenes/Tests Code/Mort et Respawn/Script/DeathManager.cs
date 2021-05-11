using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeathManager : MonoBehaviour {

    // WARNING ! THIS WHOLE SCRIPT WORKS ONLY WITH POSITIONS, THE VARIABLES WON'T BE CHANGED BY ANY MEAN (for now)
    [SerializeField] [Tooltip("Drop here every object that needs to be respawned correctly when one of the player dies")] public List<GameObject> m_objectsToRespawn = new List<GameObject>();
    [HideInInspector] public List<Vector3> m_saveState = new List<Vector3>();
    
    public delegate void Death();
    //This Delegator will be invoked each time  playable character dies
    public static Death DeathDelegator;
    
        
        //All of the tabulated code under is what it takes to make a singleton
        [SerializeField] private string m_objectName = "";
        private static DeathManager m_instance;

        public static DeathManager Instance
        {
            get
            {
                //If the death manager already exists we return it
                if (m_instance != null) return m_instance;

                //If it does not exist in the scene yet, we crate one and put it in m_instance
                m_instance = FindObjectOfType<DeathManager>();
                if (m_instance == null)
                {
                    CreateSingleton();
                }

                //If it does not exist yet, we crate one and put it in m_instance
                ((DeathManager) m_instance)?.Initialize();
                return m_instance;


            }
        }
        
        /// <summary>
        /// Create a new singleton from scratch
        /// </summary>
        private static void CreateSingleton()
        {
            GameObject singletonObject = new GameObject();
            m_instance = singletonObject.AddComponent<DeathManager>();
            singletonObject.name = "Death Manager";
        }

        private void Initialize()
        {
            if (!string.IsNullOrWhiteSpace(m_objectName))
                gameObject.name = m_objectName;
        }
        
    //The "real" code starts here
    private void Start() {
        //Not used right now, may be useful later
        //DeathDelegator += ReplaceElements;

        for (int i = 0; i < m_objectsToRespawn.Count; i++) {
            m_saveState.Add(m_objectsToRespawn[i].transform.position);
        }
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
    private void ReplaceElements() {
        Debug.Log("Death");
        for (int i = 0; i < m_objectsToRespawn.Count; i++) {
            m_objectsToRespawn[i].transform.position = m_saveState[i];
        }
    }
}
