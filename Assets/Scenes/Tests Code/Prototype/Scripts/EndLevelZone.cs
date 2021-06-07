using UnityEngine;
using UnityEngine.SceneManagement;

[RequireComponent(typeof(BoxCollider))]
public class EndLevelZone : MonoBehaviour {
    
    [SerializeField] [Tooltip("The time taken by the fade in black to occur\nUnit : seconds")] [Range(0.5f, 10f)] private float m_fadeTime = 4f;
    private bool m_creditsAreDisplayed = false;
    private bool m_levelIsCompleted = false;
    private bool m_isEndingLevel = false;

    [Header("Audio")] 
    [SerializeField] [Tooltip("Son d'ambiance")] private AudioSource m_mainTheme = null;
    
    // Start is called before the first frame update
    void Awake() {
        
        //We make sure the box collider is in trigger
        gameObject.GetComponent<BoxCollider>().isTrigger = true;

        if ( m_mainTheme != null && !m_mainTheme.isPlaying) m_mainTheme.Play();
    }

    private void Start() {
        DeathManager.Instance.DeathFade(true, m_fadeTime);
        
    }

    private void Update() {
        
        if (!m_isEndingLevel && m_levelIsCompleted) {
            m_levelIsCompleted = false;
            m_isEndingLevel = true;
            Debug.Log("DELEGATOR NEXT LEVEL ADDED !");
            //We add the function that will launch next level to the OnBlackScreen delegator so the next level will be launched once the screen is fully black
            DeathManager.OnBlackScreen = null;
            DeathManager.OnBlackScreen = new DeathManager.Death(NextLevel);
            DeathManager.Instance.DeathFade(false, m_fadeTime);
        }
    }

    private void NextLevel() {
        Debug.Log("Less goooooooooo DaBaby");
        DeathManager.OnBlackScreen -= NextLevel;
        int sceneID = SceneManager.GetActiveScene().buildIndex + 1;
        
        PlayerPrefs.SetInt("Level", sceneID);
        
        //We save the current progress of the player
        PlayerPrefs.Save();
        
        SceneManager.LoadScene(sceneID);
    }

    private void OnTriggerEnter(Collider p_other) {
        if (p_other.gameObject.TryGetComponent(out PlayerController playerScript)) {
                m_levelIsCompleted = true;
        }
    }
}
