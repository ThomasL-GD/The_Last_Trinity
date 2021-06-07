using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CreditsPage : MonoBehaviour
{
    
    [Header("Audio")] 
    [SerializeField] [Tooltip("Son d'ambiance")] private AudioSource m_mainTheme = null;

    // Start is called before the first frame update
    void Start()
    {
        if ( m_mainTheme != null && !m_mainTheme.isPlaying) m_mainTheme.Play();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.JoystickButton1) || Input.GetKeyDown(KeyCode.JoystickButton9)) {

            DeathManager.Instance.DeathFade(false, 1f);
            DeathManager.OnBlackScreen = null;
            DeathManager.OnBlackScreen += LaunchMainMenu;
            DeathManager.Instance.DeathFade(false, 1f);
        }
    }

    public void LaunchMainMenu() {
        PlayerPrefs.SetInt("Level", SceneManager.GetActiveScene().buildIndex + 1);
        SceneManager.LoadScene(0);
    }
}
