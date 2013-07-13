using UnityEngine;
using System.Collections;

public class HHInput : MonoBehaviour {

	private Vector3 lastRotation;
	public GameObject car;
	public ParticleSystem successParticle;

	// Use this for initialization
	void Start () {
		lastRotation = car.transform.localEulerAngles;
	}
	
	// Use this for initialization
	void OnLevelWasLoaded ()
	{
	
	}	
	
	// Update is called once per frame
	void Update () {
		Debug.Log( Input.deviceOrientation );
		
		bool changeOrientation = false;
		if( Input.deviceOrientation == DeviceOrientation.FaceUp )
		{
			car.transform.localEulerAngles = new Vector3( 0, 0, 0 );
		}
		else if( Input.deviceOrientation == DeviceOrientation.FaceDown )
		{
			car.transform.localEulerAngles = new Vector3( 0, -180, -180 );
		}
		else if (Input.deviceOrientation == DeviceOrientation.Portrait )
		{
			car.transform.localEulerAngles = new Vector3( 0, -90, 90 );
		}
		else if (Input.deviceOrientation == DeviceOrientation.PortraitUpsideDown )
		{
			car.transform.localEulerAngles = new Vector3( 180, -90, 90 );
		}
		else if (Input.deviceOrientation == DeviceOrientation.LandscapeLeft )
		{
			car.transform.localEulerAngles = new Vector3( 90, 180, 0 );
		}
		else if (Input.deviceOrientation == DeviceOrientation.LandscapeRight )
		{
			car.transform.localEulerAngles = new Vector3( -90, 0, 0 );
		}
		
		if( car.transform.localEulerAngles != lastRotation )
		{
			successParticle.Play();
		}
		
		lastRotation = car.transform.localEulerAngles;
	}
}


