using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel.Design.Serialization;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

[RequireComponent(typeof(BoxCollider))]
public class EndLevelZone : MonoBehaviour {
    
    [SerializeField] [Tooltip("If on, at the end of the level, the game will reboot to the main menu\nUSE IT WITH FREAKING PRECAUTIONS")] private bool m_isLastLevel = false;
    [SerializeField] [Tooltip("The chara who ill trigger the end of the level\nMost likely to be the human for every non-special level")] private Charas m_charaNeeded = Charas.Human;
    [SerializeField] [Tooltip("The time taken by the fade in black to occur\nUnit : seconds")] [Range(0.5f, 10f)] private float m_fadeTime = 4f;
    private float m_counterNextLevel = 0f;
    private bool m_levelIsCompleted = false;
    private static bool s_isEndingLevel = false;
    
    // Start is called before the first frame update
    void Awake() {
        
        //We make sure the box collider is in trigger
        gameObject.GetComponent<BoxCollider>().isTrigger = true;
    }

    private void Start() {
        DeathManager.Instance.DeathFade(true, m_fadeTime);
    }

    private void Update() {
        if (!s_isEndingLevel && m_levelIsCompleted) {
            m_levelIsCompleted = false;
            s_isEndingLevel = true;
            Debug.Log("DELEGATOR NEXT LEVEL ADDED !");
            //We add the function that will laucnh next level to the OnBlackScreen delegator so the next level will be launched once the screen is fully black
            DeathManager.OnBlackScreen += NextLevel;
            DeathManager.Instance.DeathFade(false, m_fadeTime);
        }
    }

    private void NextLevel() {
        Debug.Log("Less goooooooooo DaBaby");
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }

    private void OnTriggerEnter(Collider p_other) {
        if (p_other.gameObject.TryGetComponent(out PlayerController playerScript)) {
            if (playerScript.m_chara == m_charaNeeded) {
                m_levelIsCompleted = true;
            }
        }
    }
}
