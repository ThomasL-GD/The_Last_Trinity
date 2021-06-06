using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Audio : MonoBehaviour {
    [Header("Audio")]
    [SerializeField] [Tooltip("Son monstre qui bouffe")] private AudioSource m_monsterMunch = null;

    private void OnTriggerEnter(Collider other) {
        m_monsterMunch.Play();
    }

    private void OnTriggerExit(Collider other) {
        m_monsterMunch.Stop();
    }
}
