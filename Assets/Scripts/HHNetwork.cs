using UnityEngine;
using System.Collections;

public class HHNetwork : MonoBehaviour {

	private Vector3 lastRotation;
	public GameObject Player1;
	public GameObject Player2;
	public ParticleSystem Player1SuccessParticle;
	
	public string[] playerIDs;
	public string[] playerOrientations;
	public GameObject[] playerGameObjects;
	
	void Start()
	{
		playerIDs = new string[] { "", "" };
		playerOrientations = new string[] { "Portrait", "Portrait" };
		playerGameObjects = new GameObject[] { Player1, Player2 };
	}
	
	void Awake()
	{
		Network.InitializeServer(10,25000,false);
	}
	
	void OnServerInitialized() {
        Debug.Log("Server initialized and ready");
    }
    
   	void OnPlayerConnected() {
        Debug.Log("Player Connected");
    }

	void OnLevelWasLoaded ()
	{
		lastRotation = Player1.transform.localEulerAngles;
	}
	
	// Update is called once per frame
	void Update () {
	
		for( int i = 0; i < playerIDs.Length; i++ )
		{		
			if( playerIDs[i] != "" )
			{
				GameObject player = playerGameObjects[i];
				string currOrientation = playerOrientations[i];
				
				if( currOrientation == DeviceOrientation.FaceUp.ToString() )
				{
					player.transform.localEulerAngles = new Vector3( 0, 0, 0 );
				}
				else if( currOrientation == DeviceOrientation.FaceDown.ToString() )
				{
					player.transform.localEulerAngles = new Vector3( 0, -180, -180 );
				}
				else if ( currOrientation== DeviceOrientation.Portrait.ToString() )
				{
					player.transform.localEulerAngles = new Vector3( 0, -90, 90 );
				}
				else if ( currOrientation == DeviceOrientation.PortraitUpsideDown.ToString() )
				{
					player.transform.localEulerAngles = new Vector3( 180, -90, 90 );
				}
				else if ( currOrientation == DeviceOrientation.LandscapeLeft.ToString() )
				{
					player.transform.localEulerAngles = new Vector3( 90, 180, 0 );
				}
				else if ( currOrientation == DeviceOrientation.LandscapeRight.ToString() )
				{
					player.transform.localEulerAngles = new Vector3( -90, 0, 0 );
				}
				
				// Success particle
				if( player.transform.localEulerAngles != lastRotation )
				{
					Player1SuccessParticle.Play();
				}
			}	
		}
		
		lastRotation = Player1.transform.localEulerAngles;
	}
	
	[RPC]
    void SetOrientation( string orientation, string uniqueIdentifier ) {
  
  		for( int i = 0; i < playerIDs.Length; i++ )
		{
			if( playerIDs[i] == uniqueIdentifier )
			{
				playerOrientations[i] = orientation;
				return;
			}
			else if( playerIDs[i] == "" )
			{
				playerOrientations[i] = orientation;
				playerIDs[i] = uniqueIdentifier;
			}
		}		    	
    }
}


