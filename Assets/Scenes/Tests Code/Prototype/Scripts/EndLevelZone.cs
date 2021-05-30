using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class EndLevelZone : MonoBehaviour {
    
    [SerializeField] [Tooltip("The chara who ill trigger the end of the level\nMost likely to be the human for every non-special level")] private Charas m_charaNeeded = Charas.Human;
    
    // Start is called before the first frame update
    void Start() {
        Canvas parent = Instantiate(new Canvas());
        GameObject child = Instantiate(new GameObject(), parent.transform);
        RectTransform rect = child.AddComponent<RectTransform>();
        rect.anchorMax = new Vector2(0f, 0f);
        rect.anchorMin = new Vector2(1f, 1f);
        rect.localPosition = Vector3.zero;
        rect.anchoredPosition = Vector2.zero;
        //child.
    }
    

    private void OnTriggerEnter(Collider p_other) {
        if (p_other.gameObject.TryGetComponent(out PlayerController playerScript)) {
            if (playerScript.m_chara == m_charaNeeded) {
                
            }
        }
    }
}
