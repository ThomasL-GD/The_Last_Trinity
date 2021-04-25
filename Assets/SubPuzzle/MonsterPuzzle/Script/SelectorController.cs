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
        if (Input.GetKeyDown(KeyCode.LeftArrow) && transform.position.x > m_monsterPuzzle.m_piecesTransform[0].x)   //Déplacement a gauche si position X sélecteur > position  X  première prefab instanciée
        {
            transform.position -= new Vector3(m_monsterPuzzle.m_offsetX,0,0);
        }
        if (Input.GetKeyDown(KeyCode.RightArrow) && transform.position.x < m_monsterPuzzle.m_piecesTransform[m_monsterPuzzle.m_arrayWidth-1].x)  //Déplacement à droite si position  X sélecteur  < valeur largeur tableau prefab        // -1 parce que départ de 0
        {
            transform.position += new Vector3(m_monsterPuzzle.m_offsetX,0,0);
        }
        if (Input.GetKeyDown(KeyCode.UpArrow) && transform.position.y < m_monsterPuzzle.m_piecesTransform[0].y)  //Déplacement en haut si position Y sélecteur < position Y première prefab
        {
            transform.position += new Vector3(0,m_monsterPuzzle.m_offsetY,0);
        }
        if (Input.GetKeyDown(KeyCode.DownArrow) && transform.position.y > m_monsterPuzzle.m_piecesTransform[m_monsterPuzzle.m_arrayHeight*m_monsterPuzzle.m_arrayWidth-1].y) //Déplacement en bas si position Y sélecteur > valeur dernière prefab du tableau prefab       // -1 parce que départ de 0
        {
            transform.position -= new Vector3(0,m_monsterPuzzle.m_offsetY,0);
        }
    }
    
}
