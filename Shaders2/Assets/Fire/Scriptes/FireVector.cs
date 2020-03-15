using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class FireVector : MonoBehaviour
{
    [SerializeField] MeshRenderer[] target;

    // Update is called once per frame
    void Update()
    {
        foreach (MeshRenderer targets in target)
        {
            targets.material.SetVector("_Position", transform.position);
        }
    }
}
