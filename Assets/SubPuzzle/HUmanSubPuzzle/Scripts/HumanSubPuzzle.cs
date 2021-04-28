using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class HumanSubPuzzle : MonoBehaviour {

    public class Selector {
        public int x = 0;
        public int y = 0;
    }

    private Selector m_selector = new Selector();

    [SerializeField] [Tooltip("The height of the maze (unit : cells)")] private int m_mazeHeight = 5;
    [SerializeField] [Tooltip("The width of the maze (unit : cells)")] private int m_mazeWidth = 5;
    /*Contains every cell of the maze and if each cell have a wall above, under, on the right or on the left of itself*/private Directions[,] m_maze = null;
    
    // Start is called before the first frame update
    void Start() {
        m_maze = new Directions[m_mazeHeight, m_mazeWidth];

        //Initialization of the array, we fill it with empty cells
        for (int i = 0; i < m_maze.GetLength(0); i++) {
            for (int j = 0; j < m_maze.GetLength(1); j++) {
                m_maze[i, j] = Directions.None; //It's basically 0b0000_0000
            }
        }
        
        //Basic filler, we add a wall in a random direction to every cell in the maze
        for (int i = 0; i < m_maze.GetLength(0); i++) {
            for (int j = 0; j < m_maze.GetLength(1); j++) {
                //Here, we add a wall in a random direction to the cell we're currently on
                m_maze[i, j] = m_maze[i, j] | AssignDirections();

                //Once a cell have a wall, we update the cell(s) who touch the wall(s) we just added to make sure they know it exist
                if (m_maze[i, j] == Directions.Up) {
                    if (i > 0) m_maze[i - 1, j] = m_maze[i - 1, j] | Directions.Down;
                }
                if (m_maze[i, j] == Directions.Down) {
                    if (i < m_maze.GetLength(0) - 1) m_maze[i + 1, j] = m_maze[i + 1, j] | Directions.Up;
                }
                if (m_maze[i, j] == Directions.Left) {
                    if (j > 0) m_maze[i, j - 1] = m_maze[i, j - 1] | Directions.Right;
                }
                if (m_maze[i, j] == Directions.Right) {
                    if (j < m_maze.GetLength(1) - 1) m_maze[i, j + 1] = m_maze[i, j + 1] | Directions.Left;
                }
            }
        }
        
        //We just fill the borders with walls to avoid the player to escape
        for (int i = 0; i < m_maze.GetLength(0); i++) {
            for (int j = 0; j < m_maze.GetLength(1); j++) {
                //Up Border
                if (i == 0) m_maze[i, j] = m_maze[i, j] | Directions.Up;
                
                //Down Border
                if (i == m_maze.GetLength(0) - 1) m_maze[i, j] = m_maze[i, j] | Directions.Down;
                
                //Left Border
                if (j == 0) m_maze[i, j] = m_maze[i, j] | Directions.Left;
                
                //Right Border
                if (j == m_maze.GetLength(1) - 1) m_maze[i, j] = m_maze[i, j] | Directions.Right;
            }
        }
    }

    /// <summary>
    /// A function that is used to return a random direction using the Directions enum (and so is using bitmask)
    /// </summary>
    /// <returns>Returns a random direction</returns>
    private Directions AssignDirections() {
        Directions directions = 0b0000_0000;
        int rand = Random.Range(0, 4/*Enum.GetNames(typeof(Directions)).Length*/);
        directions = (Directions)Mathf.Pow(2, rand);
        return directions;
    }

    // Update is called once per frame
    void Update() {

        if (Input.GetKeyDown(KeyCode.LeftArrow) || Input.GetKeyDown(KeyCode.RightArrow) || Input.GetKeyDown(KeyCode.UpArrow) || Input.GetKeyDown(KeyCode.DownArrow)) {

            //déplacement du sélecteur
            //Déplacement a gauche si position X sélecteur > position  X  première prefab instanciée
            if (Input.GetKeyDown(KeyCode.LeftArrow) && m_selector.x > 0) {
                m_selector.x--;
            }
            //Déplacement à droite si position  X sélecteur  < valeur largeur tableau prefab        // -1 parce que départ de 0
            else if (Input.GetKeyDown(KeyCode.RightArrow) && m_selector.x < m_maze.GetLength(1) - 1) {
                m_selector.x++;
            }
            //Déplacement en haut si position Y sélecteur < position Y première prefab
            else if (Input.GetKeyDown(KeyCode.UpArrow) && m_selector.y > 0) {
                m_selector.y--;
            }
            //Déplacement en bas si position Y sélecteur > valeur dernière prefab du tableau prefab       // -1 parce que départ de 0
            else if (Input.GetKeyDown(KeyCode.DownArrow) && m_selector.y < m_maze.GetLength(0) - 1) {
                m_selector.y++;
            }
        }
    }
}
