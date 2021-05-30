using System;
using System.Collections;
using System.Collections.Generic;
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
        
        
    
    public void Rumble(float p_low, float p_high)
    {
        Debug.Log("Fonction A");
        m_gamepad.SetMotorSpeeds(p_low, p_high);
    }
    
    public void Rumble(float p_low, float p_high, float p_rumbleTime)
    {
        Debug.Log($"Fonction B   :      {p_high}   {p_low}      {m_gamepad}");
        m_gamepad.SetMotorSpeeds(p_low, p_high);
        StartCoroutine(RumbleDuration(p_rumbleTime));

    }

    IEnumerator RumbleDuration(float p_rumbleTime)
    {
        yield return new WaitForSeconds(p_rumbleTime);
        Debug.Log("Fonction STOP");
        StopRumble();
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