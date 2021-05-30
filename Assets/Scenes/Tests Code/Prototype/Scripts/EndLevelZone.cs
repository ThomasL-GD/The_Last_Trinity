using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

[RequireComponent(typeof(BoxCollider))]
public class EndLevelZone : MonoBehaviour {
    
    [SerializeField] [Tooltip("The chara who ill trigger the end of the level\nMost likely to be the human for every non-special level")] private Charas m_charaNeeded = Charas.Human;
    [SerializeField] [Tooltip("The time taken by the fade in black to occur\nUnit : seconds")] [Range(0.5f, 10f)] private float m_fadeTime = 4f;
    private Image m_image = null;
    private bool m_levelIsCompleted = false;
    
    // Start is called before the first frame update
    void Awake() {
        //We create a canvas and a panel inside that we will fade in black
        Canvas parent = Instantiate(new Canvas());
        GameObject child = Instantiate(new GameObject(), parent.transform);
        RectTransform rect = child.AddComponent<RectTransform>();
        Image image = child.AddComponent<Image>();
        
        //We set the rect transform in order to cover the whole screen
        rect.anchorMax = new Vector2(0f, 0f);
        rect.anchorMin = new Vector2(1f, 1f);
        rect.localPosition = Vector3.zero;
        rect.anchoredPosition = Vector2.zero;
        
        //We make the panel fully black... for now...
        image.color = new Color(0f,0f,0f, 1f);
        m_image = image;
        
        //We make sure the box collider is in trigger
        gameObject.GetComponent<BoxCollider>().isTrigger = true;
    }

    private void Update() {
        //If the screen is not transparent yet, we fade it a little more
        if (m_image.color.a != 0f && !m_levelIsCompleted) {
            float newAlpha = m_image.color.a - Time.deltaTime / m_fadeTime;

            if (newAlpha <= 0f) {
                //If the color will go under zero, we set it to zero instead
                m_image.color = new Color(0f,0f,0f, 0f);
            }
            else m_image.color = new Color(0f,0f,0f, newAlpha);
        }

        //If the player has reached the end, we fade in black and once it's faded, we start the next scene
        if (m_levelIsCompleted) {
            float newAlpha = m_image.color.a + Time.deltaTime / m_fadeTime;

            if (newAlpha >= 1f) {
                //If the color will go above one, we set it to one instead and launch the next scene
                m_image.color = new Color(0f,0f,0f, 1f);
                SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
            }
            else m_image.color = new Color(0f,0f,0f, newAlpha);
        }
    }


    private void OnTriggerEnter(Collider p_other) {
        if (p_other.gameObject.TryGetComponent(out PlayerController playerScript)) {
            if (playerScript.m_chara == m_charaNeeded) {
                m_levelIsCompleted = true;
            }
        }
    }
}
