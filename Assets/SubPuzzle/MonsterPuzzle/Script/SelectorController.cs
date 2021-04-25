using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SelectorController : MonoBehaviour
{
    //code de la génération du puzzle du monstre
    private MonsterPuzzle m_monsterPuzzle;

    private void Start()
    {
        m_monsterPuzzle = GameObject.Find("MonsterPuzzle").GetComponent<MonsterPuzzle>();
    }

    // Update is called once per frame
    void Update()
    {
        //déplacement du sélecteur
        if (Input.GetKeyDown(KeyCode.LeftArrow))
        {
            transform.position -= new Vector3(m_monsterPuzzle.m_offsetX,0,0);
        }
        if (Input.GetKeyDown(KeyCode.RightArrow))
        {
            transform.position += new Vector3(m_monsterPuzzle.m_offsetX,0,0);
        }
        if (Input.GetKeyDown(KeyCode.UpArrow))
        {
            transform.position += new Vector3(0,m_monsterPuzzle.m_offsetY,0);
        }
        if (Input.GetKeyDown(KeyCode.DownArrow))
        {
            transform.position -= new Vector3(0,m_monsterPuzzle.m_offsetY,0);
        }
    }
    
}
