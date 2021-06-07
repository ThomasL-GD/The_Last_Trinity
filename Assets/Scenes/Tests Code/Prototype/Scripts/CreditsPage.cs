using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CreditsPage : MonoBehaviour
{
    
    [Header("Audio")] 
    [SerializeField] [Tooltip("Son d'ambiance")] private AudioSource m_mainTheme = null;

    private bool m_areCreditsVisible = false;

    // Start is called before the first frame update
    void Start()
    {
        if ( m_mainTheme != null && !m_mainTheme.isPlaying) m_mainTheme.Play();
        DeathManager.Instance.DeathFade(true, 0.01f);
        DeathManager.OnTransparentScreen += DisplayedCredits;
    }

    // Update is called once per frame
    void Update()
    {
        if (m_areCreditsVisible  && Input.GetKeyDown(KeyCode.JoystickButton1) || Input.GetKeyDown(KeyCode.JoystickButton9)) {

            DeathManager.OnBlackScreen += LaunchMainMenu;
            DeathManager.Instance.DeathFade(false, 1f);
        }
    }

    public void LaunchMainMenu() {
        PlayerPrefs.SetInt("Level", SceneManager.GetActiveScene().buildIndex + 1);
        PlayerPrefs.Save();
        SceneManager.LoadScene(0);
    }
    
    private void DisplayedCredits() {
        m_areCreditsVisible = true;
    }
}
