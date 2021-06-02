using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundManager : MonoBehaviour
{
    /*
        //All of the tabulated code under is what it takes to make a singleton
        [HideInInspector] [SerializeField] private string m_objectName = "";
        private static SoundManager m_instance;
    
            public static SoundManager Instance
            {
                get
                {
                    //If the death manager already exists we return it
                    if (m_instance != null) return m_instance;
    
                    //If it does not exist in the scene yet, we crate one and put it in m_instance
                    m_instance = FindObjectOfType<SoundManager>();
                    if (m_instance == null)
                    {
                        CreateSingleton();
                    }
    
                    //If it does not exist yet, we crate one and put it in m_instance
                    ((SoundManager) m_instance)?.Initialize();
                    return m_instance;
                    
                }
            }
                
            /// <summary>
            /// Create a new singleton from scratch
            /// </summary>
            private static void CreateSingleton()
            {
                GameObject singletonObject = new GameObject();
                m_instance = singletonObject.AddComponent<SoundManager>();
                singletonObject.name = "SoundManager";
            }
            
            private void Initialize()
            {
                if (!string.IsNullOrWhiteSpace(m_objectName)) gameObject.name = m_objectName;
            }

            */

    [System.Serializable]
    public class AudioSource {
        public string m_name = "Unnamed adopted door";
        public AudioClip m_audioClip = null;
        
        public AudioSource(string p_name, AudioClip p_audioClip) {
            m_name = p_name;
            m_audioClip = p_audioClip;
        }
    }
    
    [SerializeField] [Tooltip("Liste des sons dans le jeu")] private AudioSource[] m_audioSources = new AudioSource[]{};
    
    private void Start() {

        AudioSource audio = GetComponent<AudioSource>();
        
        
    }
}
