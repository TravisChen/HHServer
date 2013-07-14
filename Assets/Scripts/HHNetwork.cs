using UnityEngine;
using System.Collections;

public class HHNetwork : MonoBehaviour {

	public Camera camera;

	public GameObject Player1;
	public GameObject Player2;
	public GameObject Player3;
	public GameObject Player4;
	
	public ParticleSystem Player1SuccessParticle;
	public ParticleSystem Player2SuccessParticle;
	public ParticleSystem Player3SuccessParticle;
	public ParticleSystem Player4SuccessParticle;
	
	public ParticleSystem Player1AppearParticle;
	public ParticleSystem Player2AppearParticle;
	public ParticleSystem Player3AppearParticle;
	public ParticleSystem Player4AppearParticle;
	
	public Material materialNormal;
	public Material materialDark;

	// Timer
	public GameObject TimerLabel;
	public ParticleSystem TimerParticle;
	public ParticleSystem TimerParticleEnd;
	private bool gameStarted = false;
	private float timerMax = 11.0f;
	private float timer = 0.0f;

	
	private int minPlayers = 1;
	private string[] playerIDs;
	private string[] playerOrientations;
	private string[] playerLastOrientations;
	private ParticleSystem[] playerParticles;
	private ParticleSystem[] playerAppearParticles;
	private GameObject[] playerGameObjects;
	
	void Start()
	{
		playerIDs = new string[] { "", "", "", "" };
		playerOrientations = new string[] { "Portrait", "Portrait", "Portrait",  "Portrait" };
		playerLastOrientations = new string[] { "Portrait", "Portrait", "Portrait", "Portrait" };
		playerGameObjects = new GameObject[] { Player1, Player2, Player3, Player4 };
		playerParticles = new ParticleSystem[] { Player1SuccessParticle, Player2SuccessParticle, Player3SuccessParticle, Player4SuccessParticle };
		playerAppearParticles = new ParticleSystem[] { Player1AppearParticle, Player2AppearParticle, Player3AppearParticle, Player4AppearParticle };
    
		for( int i = 0; i < playerGameObjects.Length; i++ )
		{
			GameObject player = playerGameObjects[i];
			MeshRenderer renderer = player.transform.Find( "AnimatedSprite" ).GetComponent<MeshRenderer>();
			renderer.material = materialDark;
		}
		
		// Timer
		timer = timerMax;
		TimerParticle.Play();
	}
	
	void Awake()
	{
		Network.InitializeServer(10,25000,false);
	}
	
	void OnServerInitialized() {
        Debug.Log("Server initialized and ready");
    }
    
    void UpdateTimer() {
    
    	if( GameReady() )
    	{
    		gameStarted = true;
    		TimerLabel.SetActive( true );
    		TimerParticle.gameObject.SetActive( true );
	    	tk2dTextMesh timerText = TimerLabel.GetComponent<tk2dTextMesh>();
			if( timerText )
			{
				timer -= Time.deltaTime;
				timerText.text = "" + (int)timer + "";
				timerText.Commit();
				
				if( timer <= 1 )
				{
					TimerParticleEnd.Play();
					timer = timerMax;
				}
			}
		}
		else
		{
			TimerLabel.SetActive( false );
			TimerParticle.gameObject.SetActive( false );
		}
		
    }
	
	void UpdateEffect() {
		CC_AnalogTV tvEffect = camera.GetComponent<CC_AnalogTV>();
		tvEffect.noiseIntensity = (Random.value * 0.1f) + 0.05f;
		tvEffect.scanlinesCount = Random.Range(250,300);
	}
	
	// Update is called once per frame
	void Update () {
	
		// Timer
		UpdateTimer();
		
		// Effect
		UpdateEffect();
		
		for( int i = 0; i < playerIDs.Length; i++ )
		{	
			// Player
			GameObject player = playerGameObjects[i];
			string currOrientation = playerOrientations[i];
			tk2dSprite sprite = player.transform.Find( "AnimatedSprite" ).GetComponent<tk2dSprite>();
			tk2dSpriteAnimator animator = player.transform.Find( "AnimatedSprite" ).GetComponent<tk2dSpriteAnimator>();
				
			// Set instruction text
			tk2dTextMesh instruction = player.transform.Find( "Instruction" ).GetComponent<tk2dTextMesh>();
			player.transform.Find( "Instruction" ).gameObject.SetActive( false );
			instruction.text = "TEST";
			instruction.Commit();
					
			if( playerIDs[i] != "" )
			{		

				sprite.FlipX = false;
				
				if( currOrientation == DeviceOrientation.FaceUp.ToString() )
				{
					animator.Play( "FaceUp" );
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
					animator.Play( "ButtUp" );
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
	
	bool GameReady() {
		for( int i = 0; i < playerIDs.Length; i++ )
		{
			if( playerIDs[i] == "" )
			{
				if( i >= minPlayers )
				{
					return true;
				}
				else
				{
					return false;
				}
			}		
		}
		return true;
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
				if( !gameStarted )
				{
					playerOrientations[i] = orientation;
					playerLastOrientations[i] = orientation;
					playerIDs[i] = uniqueIdentifier;
					playerGameObjects[i].SetActive(true);
					playerAppearParticles[i].Play();
					
					GameObject player = playerGameObjects[i];
					MeshRenderer renderer = player.transform.Find( "AnimatedSprite" ).GetComponent<MeshRenderer>();
					renderer.material = materialNormal;
				}
				return;
			}
		}		    	
    }
}


