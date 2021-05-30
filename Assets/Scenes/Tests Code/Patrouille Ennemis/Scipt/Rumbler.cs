using System;
using System.Linq;
using UnityEngine;
using UnityEngine.InputSystem;

public class Rumbler : MonoBehaviour
{
    [HideInInspector] public PlayerInput m_playerInput;
    Gamepad m_gamepad = Gamepad.current;
     
    // private void OnEnable()
    // {
    //     Gamepad m_gamepad = Gamepad.current;
    // }

    
    //All of the tabulated code under is what it takes to make a singleton
    [HideInInspector] [SerializeField] private string m_objectName = "";
    private static Rumbler m_instance;

        public static Rumbler Instance
        {
            get
            {
                //If the death manager already exists we return it
                if (m_instance != null) return m_instance;

                //If it does not exist in the scene yet, we crate one and put it in m_instance
                m_instance = FindObjectOfType<Rumbler>();
                if (m_instance == null)
                {
                    CreateSingleton();
                }

                //If it does not exist yet, we crate one and put it in m_instance
                ((Rumbler) m_instance)?.Initialize();
                return m_instance;
                
            }
        }
            
        /// <summary>
        /// Create a new singleton from scratch
        /// </summary>
        private static void CreateSingleton()
        {
            GameObject singletonObject = new GameObject();
            m_instance = singletonObject.AddComponent<Rumbler>();
            singletonObject.name = "Rumbler";
        }
        
        private void Initialize()
        {
            if (!string.IsNullOrWhiteSpace(m_objectName)) gameObject.name = m_objectName;
        }





    /// <summary>
    /// Fonction de vibration lors de compétence du monstre allié dans le script GuardBehavior
    /// </summary>
    /// <param name="p_low"> vitesse de vibration moteur bas</param>
    /// <param name="p_high">vitesse de vibration moteur haut</param>
    /// <param name="p_duration"></param>
    public void Intimidate(float p_low, float p_high) {
        m_gamepad.SetMotorSpeeds(p_low, p_high);
        
        //insérer timer et appel StopRumble
    }

    /// <summary>
    /// Fonction de vibration de détection mais pas de vision dans le script GuardBehavior
    /// </summary>
    /// <param name="p_low"> vitesse de vibration moteur bas</param>
    /// <param name="p_high">vitesse de vibration moteur haut</param>
    /// <param name="p_duration"></param>
    public void Warning(float p_low, float p_high)
    {
        m_gamepad.SetMotorSpeeds(p_low, p_high);
        
        Debug.Log($"valeur du moteur bas lors d'une détection proche: {p_low}");
        //insérer timer et appel StopRumble
    }
    
    /// <summary>
    /// Fonction de vibration d'attaque de monstre ennemi dans le script GuardBehavior
    /// </summary>
    /// <param name="p_low"> vitesse de vibration moteur bas</param>
    /// <param name="p_high">vitesse de vibration moteur haut</param>
    public void Attack(float p_low, float p_high)
    {
        m_gamepad.SetMotorSpeeds(p_low, p_high);
        
        Debug.Log($"valeur du moteur bas lors d'une attaque: {p_low}");
        //insérer timer et appel StopRumble
    }
    
    /// <summary>
    /// Fonction de vibration lors de fonçage dans un mur dans le script HumanSubPuzzle
    /// </summary>
    /// <param name="p_low"> vitesse de vibration moteur bas</param>
    /// <param name="p_high">vitesse de vibration moteur haut</param>
    public void HumanSubPuzzle(float p_low, float p_high)
    {
        m_gamepad.SetMotorSpeeds(p_low, p_high);
        
        Debug.Log($"valeur du moteur bas lors d'une erreur dans subPuzzle humaine: {p_low}");
        //insérer timer et appel StopRumble
    }
    
    /// <summary>
    /// Fonction de vibration lors d'échec dans le script MonsterSubPuzzle
    /// </summary>
    /// <param name="p_low"> vitesse de vibration moteur bas</param>
    /// <param name="p_high">vitesse de vibration moteur haut</param>
    public void MonsterPuzzle(float p_low, float p_high, float p_vibeTime)
    {
        m_gamepad.SetMotorSpeeds(p_low, p_high);
        
        //insérer timer et appel StopRumble
    }


    

    public void StopRumble()
    {
        m_gamepad.SetMotorSpeeds(0, 0);
    }
    
    
    
    // Unity MonoBehaviors
    private void Awake()
    {
        m_playerInput = GetComponent<PlayerInput>();
        m_gamepad = GetGamepad();
    }

    private void Update()
    {
        /*
        if (Time.time > m_rumbleDurration)
        {
            StopRumble();
            return;
        }
        
        if (m_gamepad == null) return;
        m_gamepad.SetMotorSpeeds(m_lowA, m_highA);
        */
    }


    // Private helpers
    private Gamepad GetGamepad()
    {
        //return Gamepad.all.FirstOrDefault(g => m_playerInput.devices.Any(d => d.deviceId == g.deviceId));
        return Gamepad.current;
        
        #region Linq Query Equivalent Logic
        //Gamepad gamepad = null;
        //foreach (var g in Gamepad.all)
        //{
        //    foreach (var d in _playerInput.devices)
        //    {
        //        if(d.deviceId == g.deviceId)
        //        {
        //            gamepad = g;
        //            break;
        //        }
        //    }
        //    if(gamepad != null)
        //    {
        //        break;
        //    }
        //}
        //return gamepad;
        #endregion
    }
}