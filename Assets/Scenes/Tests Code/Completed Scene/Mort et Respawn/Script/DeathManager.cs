using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class DeathManager : MonoBehaviour {

    [SerializeField] [Tooltip("The canvas of the scene, if null, will use a find instead\n(and that's bad coz not opti)")] private GameObject m_canvas = null;
    private Image m_image = null;
    private float m_targetOpacity = 1f;
    private float m_fadeTime = 4f;
    
    public delegate void Death();
    //This Delegator will be invoked each time  playable character dies
    public static Death DeathDelegator;
    public static Death OnBlackScreen;
    public static Death OnTransparentScreen;
    
        
        //All of the tabulated code under is what it takes to make a singleton
        [SerializeField] private string m_objectName = "";
        private static DeathManager m_instance;

        public static DeathManager Instance
        {
            get
            {
                //If the death manager already exists we return it
                if (m_instance != null) return m_instance;

                //If it does not exist in the scene yet, we crate one and put it in m_instance
                m_instance = FindObjectOfType<DeathManager>();
                if (m_instance == null)
                {
                    CreateSingleton();
                }

                //If it does not exist yet, we crate one and put it in m_instance
                ((DeathManager) m_instance)?.Initialize();
                return m_instance;


            }
        }
        
        /// <summary>
        /// Create a new singleton from scratch
        /// </summary>
        private static void CreateSingleton()
        {
            GameObject singletonObject = new GameObject();
            m_instance = singletonObject.AddComponent<DeathManager>();
            singletonObject.name = "Death Manager";
        }

        private void Initialize()
        {
            if (!string.IsNullOrWhiteSpace(m_objectName)) gameObject.name = m_objectName;
        }
        
    //The "real" code starts here
    
    //Technically, thanks to EndLevelZone script, this script will be enabled on the first frame
    private void OnEnable() {
        if (m_canvas == null) {
            Debug.LogWarning("*Blue's voice* You didn't serialized the canvas in the death manager but I'll try to find a way anyway, if it won't work, you'll have an error right below. Serialize it correctly next time", this);
            
            m_canvas = GameObject.FindObjectOfType<Canvas>().gameObject;
            if (m_canvas == null) {
                Debug.LogError("JEEZ ! THERE'S NO CANVAS ON THIS SCENE ! HOW DO YOU EXPECT ME TO DO A FADE IN BLACK ?!", this);
            }
        }
        
        
        //We create a panel that we will fade in black
        GameObject child = Instantiate(new GameObject(), m_canvas.transform);
        child.name = "Fade in Black";
        RectTransform rect = child.AddComponent<RectTransform>();
        Image image = child.AddComponent<Image>();
        
        //We set the rect transform in order to cover the whole screen
        rect.anchorMin = new Vector2(0f, 0f);
        rect.anchorMax = new Vector2(1f, 1f);
        rect.localPosition = Vector3.zero;
        rect.anchoredPosition = Vector2.zero;
        
        //We make the panel fully black... for now...
        image.color = new Color(0f,0f,0f, 1f);
        m_image = image;
        
    }

    private void Update() {
        
        //If the screen is not as transparent as we want yet, we fade it a little more
        if (m_image.color.a != m_targetOpacity) {
            
            //We increase or decrease the alpha according to the wanted color
            float newAlpha = m_image.color.a;
            if (m_targetOpacity == 0f) {
                newAlpha -= Time.deltaTime / m_fadeTime;
            }else if (m_targetOpacity == 1f) {
                newAlpha += Time.deltaTime / m_fadeTime;
            }else{
                Debug.LogError("The precision of the float has been fucked up, call Blue immediately if this error occurs", this);
            }

            if (newAlpha < 0f && m_targetOpacity == 0f) {
                //If the color will go under zero, we set it to zero instead and Invoke the associate delegator
                m_image.color = new Color(0f,0f,0f, m_targetOpacity);
                OnTransparentScreen?.Invoke(); //We call the delegator if it is not empty
            }
            else if (newAlpha > 1f && m_targetOpacity == 1f) {
                //If the color will go above one, we set it to one instead
                m_image.color = new Color(0f,0f,0f, m_targetOpacity);
                OnBlackScreen?.Invoke(); //We call the delegator if it is not empty
            }
            else m_image.color = new Color(0f,0f,0f, newAlpha);
        }
        
        //To delete when we're gonna remove all the Debug.LogError
        if (Input.GetKeyDown(KeyCode.F1)) {
            SceneManager.LoadScene(1);
        } else if (Input.GetKeyDown(KeyCode.F2)) {
            SceneManager.LoadScene(2);
        } else if (Input.GetKeyDown(KeyCode.F3)) {
            SceneManager.LoadScene(3);
        }
    }

    /// <summary>
    /// Will fade the screen to black or to transparent
    /// Once it's fully faded, the appropriate delegator (OnTransparentScreen or OnBlackScreen) will be invoked
    /// </summary>
    /// <param name="p_isFadingTowardsTransparent">if on, will fade to transparent. If off, will fade to black</param>
    /// <param name="p_time">The length of the fade in seconds</param>
    public void DeathFade(bool p_isFadingTowardsTransparent, float p_time) {
        
        if (p_isFadingTowardsTransparent && m_targetOpacity == 0f) {
            Debug.LogWarning("Watch out ! you're trying to fade to transparent but it's already fading to transparent ...");
        }
        else if (!p_isFadingTowardsTransparent && m_targetOpacity == 1f) {
            Debug.LogWarning("Watch out ! you're trying to fade to black but it's already fading to black ...");
        }
        else {
            m_targetOpacity = 1f;
            if (p_isFadingTowardsTransparent) m_targetOpacity = 0f;
        }

        m_fadeTime = p_time;
    }
}
