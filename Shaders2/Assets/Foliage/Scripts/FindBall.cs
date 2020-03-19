using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FindBall : MonoBehaviour
{
    public MeshRenderer[] meshRend;
    void Start()
    {
        meshRend = FindObjectsOfType<MeshRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        foreach(MeshRenderer mesh in meshRend)
        {
            mesh.material.SetFloat("_ObjectRadius", transform.localScale.x);
            mesh.material.SetVector("_ObjectPosition", transform.position);
        }
    }
}
