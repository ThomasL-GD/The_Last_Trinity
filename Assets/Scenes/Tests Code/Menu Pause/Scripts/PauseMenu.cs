using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PauseMenu : MonoBehaviour
{

    private bool m_isPausing = false; //Booléen qui dit quand le jeu est en pause ou non. 
    


    // Update is called once per frame
    void Update()
    {
        if (!m_isPausing)
        {
            if (Input.GetKeyDown(KeyCode.Joystick1Button9))
            {
                m_isPausing = true;
                Time.timeScale = 0;
                Debug.Log("EN PAUSE");
                //gameObject.SetActive(true);
                //gameObject.GetComponent<Canvas>().enabled = true;

            }
        }
        else if (m_isPausing)
        {
            if (Input.GetKeyDown(KeyCode.Joystick1Button9))
            {
                m_isPausing = false;
                Time.timeScale = 1;
                Debug.Log("JEU EN COURS");
                //gameObject.SetActive(false);
            }
        }
    }
}
