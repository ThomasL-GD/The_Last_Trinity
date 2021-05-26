using System.Linq;
using UnityEngine;
using UnityEngine.InputSystem;

public class Rumbler : MonoBehaviour
{
    [HideInInspector] public PlayerInput m_playerInput;
    [SerializeField] [Range(0f,10f)] private float m_rumbleDurration = 0f;
    [SerializeField] [Range(0f,1f)] private float m_lowA =0f;
    [SerializeField] [Range(0f,1f)] private float m_highA =0f;
    Gamepad m_gamepad = Gamepad.current;
    public void StopRumble()
    {
        if (m_gamepad != null) m_gamepad.SetMotorSpeeds(0, 0);
    }
    
    // Unity MonoBehaviors
    private void Awake()
    {
        m_playerInput = GetComponent<PlayerInput>();
        m_gamepad = GetGamepad();
    }

    private void Update()
    {
        if (Time.time > m_rumbleDurration)
        {
            StopRumble();
            return;
        }

        
        if (m_gamepad == null) return;

        m_gamepad.SetMotorSpeeds(m_lowA, m_highA);
    }
    
    private void OnDestroy()
    {
        StopAllCoroutines();
        StopRumble();
    }

    
    // Private helpers
    private Gamepad GetGamepad()
    {
        return Gamepad.all.FirstOrDefault(g => m_playerInput.devices.Any(d => d.deviceId == g.deviceId));

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