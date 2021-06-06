using System;
using UnityEngine;

public class Audio : MonoBehaviour {
    [Header("Audio")]
    [SerializeField] [Tooltip("Son du monstre qui bouffe")] private AudioSource m_mainSound = null;
    [SerializeField] [Tooltip("délai avant que le son ne se joue")] [Range(0.0f, 10.0f)] private float m_delay = 0.0f;
    private bool m_hasBeenPlayed = false;
    
    private void OnTriggerEnter(Collider other) {
        
        //ne se joue qu'une fois
        if (m_delay > 1.0f && !m_hasBeenPlayed) {
            m_hasBeenPlayed = true;
            m_mainSound.PlayDelayed(m_delay);
        }
        //se joue à chaque fois
        else if(m_delay < 1.0f){
             m_mainSound.Play();
        }
    }

    private void OnTriggerExit(Collider other) {
        m_mainSound.Stop();
    }
    
}
