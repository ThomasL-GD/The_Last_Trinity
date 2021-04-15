using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeathZone : MonoBehaviour {

    [SerializeField] [Tooltip("The time the player is allowed to stay in this death zone (unit : seconds)")] private float m_timeBeforeDying = 0.5f;
    private float m_counter = 0.0f;
    private bool m_isKilling = false;


    private void Start() {
        DeathManager.DeathDelegator += ResetValues;
    }

    private void Update() {
        if (!m_isKilling && m_counter > 0f) {
            m_counter -= Time.deltaTime;
        }
        else if (m_isKilling) {
            m_counter += Time.deltaTime;
        }
    }

    /// <summary>
    /// Is called every frame as long as something is triggering the hitbox
    /// It is detecting the trigger with every playable character to be able to kill him if he stays too long in there
    /// </summary>
    /// <param name="p_other">The Collider of the object we're triggering with</param>
    private void OnTriggerStay(Collider p_other) {
        //We can detect if it is a player or not by checking if it has a PlayerController script
        if (p_other.gameObject.TryGetComponent(out PlayerController pScript)) {
            m_isKilling = true;
            if (m_counter > m_timeBeforeDying) {
                //The line below means that if the delegator is NOT empty, we invoke it.
                DeathManager.DeathDelegator?.Invoke();
            }
        }
        
    }

    /// <summary>
    /// Just to stop running the timer
    /// </summary>
    /// <param name="p_other"></param>
    private void OnTriggerExit(Collider p_other) {
        if (p_other.gameObject.TryGetComponent(out PlayerController pScript)) {
            m_isKilling = false;
        }
    }

    /// <summary>
    /// For safety, we reset a few values in case of death & respawn
    /// </summary>
    private void ResetValues() {
        m_isKilling = false;
        m_counter = 0.0f;
    }
}
