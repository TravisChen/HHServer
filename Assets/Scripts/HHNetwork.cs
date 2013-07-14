using UnityEngine;
using System.Collections;

public class HHNetwork : MonoBehaviour {

	public GameObject Player1;
	public GameObject Player2;
	
	public ParticleSystem Player1SuccessParticle;
	public ParticleSystem Player2SuccessParticle;
	
	public ParticleSystem Player1AppearParticle;
	public ParticleSystem Player2AppearParticle;
	
	public string[] playerIDs;
	public string[] playerOrientations;
	public string[] playerLastOrientations;
	public ParticleSystem[] playerParticles;
	public ParticleSystem[] playerAppearParticles;
	public GameObject[] playerGameObjects;
	
	void Start()
	{
		playerIDs = new string[] { "", "" };
		playerOrientations = new string[] { "Portrait", "Portrait" };
		playerLastOrientations = new string[] { "Portrait", "Portrait" };
		playerGameObjects = new GameObject[] { Player1, Player2 };
		playerParticles = new ParticleSystem[] { Player1SuccessParticle, Player2SuccessParticle };
		playerAppearParticles = new ParticleSystem[] { Player1AppearParticle, Player2AppearParticle };
		
//		for( int i = 0; i < playerGameObjects.Length; i++ )
//		{
//			playerGameObjects[i].SetActive(false);
//		}
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
	
	// Update is called once per frame
	void Update () {
	
		for( int i = 0; i < playerIDs.Length; i++ )
		{	

			// Player
			GameObject player = playerGameObjects[i];
				
			// Set instruction text
			tk2dTextMesh instruction = player.transform.Find( "Instruction" ).GetComponent<tk2dTextMesh>();
			instruction.text = "TEST";
			instruction.Commit();
					
			if( playerIDs[i] != "" )
			{		
				string currOrientation = playerOrientations[i];
				tk2dSprite sprite = player.transform.Find( "AnimatedSprite" ).GetComponent<tk2dSprite>();
				tk2dSpriteAnimator animator = player.transform.Find( "AnimatedSprite" ).GetComponent<tk2dSpriteAnimator>();
				
				sprite.FlipX = false;
				
				if( currOrientation == DeviceOrientation.FaceUp.ToString() )
				{
					animator.Play( "Portrait" );
					//player.transform.localEulerAngles = new Vector3( 0, 0, 0 );
				}
				else if( currOrientation == DeviceOrientation.FaceDown.ToString() )
				{
					animator.Play( "FaceDown" );
					//player.transform.localEulerAngles = new Vector3( 0, -180, -180 );
				}
				else if ( currOrientation== DeviceOrientation.Portrait.ToString() )
				{
					animator.Play( "Portrait" );	
					//player.transform.localEulerAngles = new Vector3( 0, -90, 90 );
				}
				else if ( currOrientation == DeviceOrientation.PortraitUpsideDown.ToString() )
				{
					animator.Play( "Portrait" );
					//player.transform.localEulerAngles = new Vector3( 180, -90, 90 );
				}
				else if ( currOrientation == DeviceOrientation.LandscapeLeft.ToString() )
				{
					sprite.FlipX = true;
					animator.Play( "Side" );
					//player.transform.localEulerAngles = new Vector3( 90, 180, 0 );
				}
				else if ( currOrientation == DeviceOrientation.LandscapeRight.ToString() )
				{
					animator.Play( "Side" );
					//player.transform.localEulerAngles = new Vector3( -90, 0, 0 );
				}
				
				// Success particle
				if( currOrientation != playerLastOrientations[i] )
				{
					playerParticles[i].Play();
				}
				
				playerLastOrientations[i] = currOrientation;
			}	
		}
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
				playerLastOrientations[i] = orientation;
				playerIDs[i] = uniqueIdentifier;
				playerGameObjects[i].SetActive(true);
				playerAppearParticles[i].Play();
				return;
			}
		}		    	
    }
}


