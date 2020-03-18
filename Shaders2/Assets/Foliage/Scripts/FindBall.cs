using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FindBall : MonoBehaviour
{
    MeshRenderer[] meshRend;
    void Start()
    {
        meshRend = FindObjectsOfType<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        foreach(MeshRenderer mesh in meshRend)
        {
            mesh.material.SetVector("_ObjectPosition", transform.position);
        }
    }
}
