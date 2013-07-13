using UnityEngine;
using System.Collections;

public class MobileInput : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Use this for initialization
	void OnLevelWasLoaded ()
	{
	
	}	
	
	// Update is called once per frame
	void Update () {
		Debug.Log( Input.deviceOrientation );
	}
}


