using UnityEngine;
using System.Collections;

public class HHNetwork : MonoBehaviour {

	public Camera camera;
	public HHAudioManager audio;

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

	public GameObject getReadyMenu;
	public GameObject winMenu;
	public GameObject restartMenu;

	// Timer
	public GameObject TimerLabel;
	public ParticleSystem TimerParticle;
	public ParticleSystem TimerParticleEnd;
	private bool gameStarted = false;
	private bool controlsSet = false;
	private bool gameOver = false;
	private float timerMax = 11.0f;
	private float timer = 0.0f;
	private float startTimer = 3.0f;
	private float restartTimer = 5.0f;
	private float restartCountdown = 11.0f;
	
	private int minPlayers = 4;
	private string[] playerIDs;
	private string[] availableOrientations;
	private string[] playerOrientations;
	private string[] playerGoalOrientations;
	private bool[] playerGoalCompleted;
	private bool[] playerFailed;

	private ParticleSystem[] playerParticles;
	private ParticleSystem[] playerAppearParticles;
	private GameObject[] playerGameObjects;
	
	void Start()
	{
		playerIDs = new string[] { "", "", "", "" };
		
		availableOrientations = new string[] { "FaceUp", "FaceDown", "Portrait", "PortraitUpsideDown", "LandscapeLeft", "Hug", "Think" };
		playerOrientations = new string[] { "Portrait", "Portrait", "Portrait",  "Portrait" };
		playerGoalOrientations = new string[] { "Portrait", "Portrait", "Portrait",  "Portrait" };
		playerGoalCompleted = new bool[] { false, false, false, false };
		playerFailed = new bool[] { false, false, false, false };
		
		playerGameObjects = new GameObject[] { Player1, Player2, Player3, Player4 };
		playerParticles = new ParticleSystem[] { Player1SuccessParticle, Player2SuccessParticle, Player3SuccessParticle, Player4SuccessParticle };
		playerAppearParticles = new ParticleSystem[] { Player1AppearParticle, Player2AppearParticle, Player3AppearParticle, Player4AppearParticle };
    
		for( int i = 0; i < playerGameObjects.Length; i++ )
		{
			GameObject player = playerGameObjects[i];
			MeshRenderer renderer = player.transform.Find( "AnimatedSprite" ).GetComponent<MeshRenderer>();
			renderer.material = materialDark;
		}
		
		// Disable menus
		getReadyMenu.SetActive( false );
		winMenu.SetActive( false );
		restartMenu.SetActive( false );
		
		// Timer
		timer = timerMax;
		TimerParticle.Play();
	}
	
	void ResetGame()
	{
		playerOrientations = new string[] { "Portrait", "Portrait", "Portrait",  "Portrait" };
		playerGoalOrientations = new string[] { "Portrait", "Portrait", "Portrait",  "Portrait" };
		playerGoalCompleted = new bool[] { false, false, false, false };
		playerFailed = new bool[] { false, false, false, false };
		
		getReadyMenu.SetActive( false );
		winMenu.SetActive( false );
		restartMenu.SetActive( false );
		
		gameStarted = false;
		gameOver = false;
		timer = timerMax;
		startTimer = 3.0f;
		restartTimer = 5.0f;
		restartCountdown = 11.0f;

		for( int i = 0; i < playerGameObjects.Length; i++ )
		{
			playerFailed[i] = false;
			playerGameObjects[i].SetActive( true );
		}
	}
	
	void Awake()
	{
		Network.InitializeServer(10,25000,false);
	}
	
	void OnServerInitialized() {
        Debug.Log("Server initialized and ready");
    }
    
    void UpdateTimer() {
    
    	if( GameReady() && !gameOver )
    	{
    		if( startTimer <= 0 )
    		{
    			getReadyMenu.SetActive( false );
    			
	    		// First start
	    		if( !gameStarted )
	    		{
	    		    TimerLabel.SetActive( true );
	    			TimerParticle.gameObject.SetActive( true );
	    			SetGoalOrientations();
	    			gameStarted = true;
	    		}
	
		    	tk2dTextMesh timerText = TimerLabel.GetComponent<tk2dTextMesh>();
				if( timerText )
				{
					timer -= Time.deltaTime;
					timerText.text = "" + (int)timer + "";
					timerText.Commit();
					
					if( timer <= 1 )
					{
						// END ROUND, NEXT ROUND
						SetGoalOrientations();
						TimerParticleEnd.Play();
						timer = timerMax;
						
						audio.playWhistle();
						
						// Reset all players
						for( int i = 0; i < playerGoalCompleted.Length; i++ )
						{
							if( !playerGoalCompleted[i] && !playerFailed[i] )
							{
								playerFailed[i] = true;
								if( playerIDs[i] != "" )
								{
									playerAppearParticles[i].Play();
									audio.playBust();
								}
								playerGameObjects[i].SetActive( false );

							}
							CheckGameOver();
							playerGoalCompleted[i] = false;
							playerParticles[i].Stop();
						}
					}
				}
			}
			else
			{
				if( startTimer >= 3.0f )
				{
					audio.randomSong();
				}
				getReadyMenu.SetActive( true );
				TurnOffNotPlaying();
				startTimer -= Time.deltaTime;
			}
		}
		else
		{
			TimerLabel.SetActive( false );
			TimerParticle.gameObject.SetActive( false );
			
			if( gameOver )
			{
				CheckRestart();
			}
		}
		
    }
    
    void CheckRestart() {

		restartTimer -= Time.deltaTime;
		if( restartTimer <= 0 )
		{
			winMenu.SetActive( false );
			restartMenu.SetActive( true );
			
			tk2dTextMesh restartTimerLabel = restartMenu.transform.Find( "RestartTimer" ).GetComponent<tk2dTextMesh>();
			restartTimerLabel.text = "" + (int)restartCountdown + "";
			restartTimerLabel.Commit();
			
			restartCountdown -= Time.deltaTime;
			
			if( restartCountdown <= 0 )
			{
				ResetGame();
			}
		}
    	
    }
    
    void CheckGameOver() {
    
    	int numAlive = 0;
    	int winner = 0;   	
    	for( int i = 0; i < playerFailed.Length; i++ )
		{
			if( !playerFailed[i] )
			{
				numAlive++;
				winner = i;
			}
		}
		
		if( numAlive <= 1 )
		{
			winMenu.SetActive( true );
			gameOver = true;
			
			tk2dTextMesh playerNumLabel = winMenu.transform.Find( "PlayerNum" ).GetComponent<tk2dTextMesh>();
			tk2dTextMesh winsLabel = winMenu.transform.Find( "WINS" ).GetComponent<tk2dTextMesh>();
			if( numAlive == 0 )
			{
				playerNumLabel.text = "0";	
				winsLabel.text = "TIE.";	
			}
			else
			{
				playerNumLabel.text = "" + ( winner + 1 ) + "";
			}
			playerNumLabel.Commit();
			winsLabel.Commit();
			
			restartTimer = 5.0f;
			restartCountdown = 11.0f;
		}
    }
    
    void SetGoalOrientations() {
    
    	for( int i = 0; i < playerIDs.Length; i++ )
		{
			int randomOrientation = Random.Range( 0, availableOrientations.Length );
			string randomOrientationString = availableOrientations[randomOrientation];
			
			string currOrientation = playerOrientations[i];
			if( randomOrientationString == currOrientation || randomOrientationString == playerGoalOrientations[i] )
			{
				SetGoalOrientations();
				return;
			}
			else
			{
				playerGoalOrientations[i] = randomOrientationString;
			}

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
		
		if( !gameStarted || gameOver )
		{
			return;
		}
		
		for( int i = 0; i < playerIDs.Length; i++ )
		{	
			// Player
			GameObject player = playerGameObjects[i];
			string currOrientation = playerOrientations[i];
			tk2dSprite sprite = player.transform.Find( "AnimatedSprite" ).GetComponent<tk2dSprite>();
			tk2dSpriteAnimator animator = player.transform.Find( "AnimatedSprite" ).GetComponent<tk2dSpriteAnimator>();
			
					
//			// Set instruction text
//			tk2dTextMesh instruction = player.transform.Find( "Instruction" ).GetComponent<tk2dTextMesh>();
//			instruction.text = "";
//			instruction.Commit();
					
			if( playerIDs[i] != "" && !playerFailed[i] )
			{
				sprite.FlipX = false;
				
				if( playerGoalOrientations[i] == "FaceUp" )
				{
					animator.Play( "FaceUp" );
					//player.transform.localEulerAngles = new Vector3( 0, 0, 0 );
				}
				else if( playerGoalOrientations[i] == "FaceDown" )
				{
					animator.Play( "FaceDown" );
					//player.transform.localEulerAngles = new Vector3( 0, -180, -180 );
				}
				else if ( playerGoalOrientations[i] == "Portrait" )
				{
					animator.Play( "Portrait" );	
					//player.transform.localEulerAngles = new Vector3( 0, -90, 90 );
				}
				else if ( playerGoalOrientations[i] == "PortraitUpsideDown" )
				{
					animator.Play( "ButtUp" );
					//player.transform.localEulerAngles = new Vector3( 180, -90, 90 );
				}
				else if ( playerGoalOrientations[i] == "LandscapeLeft" || playerGoalOrientations[i] == "LandscapeRight" )
				{
					animator.Play( "Side" );
					//player.transform.localEulerAngles = new Vector3( -90, 0, 0 );
				}
				else if ( playerGoalOrientations[i] == "Hug" )
				{
					animator.Play( "Hug" );
					//player.transform.localEulerAngles = new Vector3( -90, 0, 0 );
				}
				else if ( playerGoalOrientations[i] == "Think" )
				{
					animator.Play( "Think" );
					//player.transform.localEulerAngles = new Vector3( -90, 0, 0 );
				}
				
				
				// Success particle
				if( currOrientation == playerGoalOrientations[i] && !playerGoalCompleted[i]  )
				{
					playerParticles[i].Play();
					playerGoalCompleted[i] = true;
					audio.playYay();
				}
				
				// LANDSCAPE HACK
				if( playerGoalOrientations[i] == "LandscapeLeft" && !playerGoalCompleted[i] )
				{
					if( currOrientation == "LandscapeLeft" || currOrientation == "LandscapeRight" )
					{
						playerParticles[i].Play();
						playerGoalCompleted[i] = true;		
						audio.playYay();				
					}
				} 
				
				// HUG HACK!
				if( playerGoalOrientations[i] == "Hug" && !playerGoalCompleted[i] )
				{
					if( timer < 3.0 )
					{
						playerParticles[i].Play();
						playerGoalCompleted[i] = true;
						audio.playYay();
					}
				}
				
				// HUG HACK!
				if( playerGoalOrientations[i] == "Think" && !playerGoalCompleted[i] )
				{
					if( timer < 5.0 )
					{
						playerParticles[i].Play();
						playerGoalCompleted[i] = true;
						audio.playYay();
					}
				}
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
	
	void TurnOffNotPlaying() {
		for( int i = 0; i < playerIDs.Length; i++ )
		{
			if( playerIDs[i] == "" )
			{
				playerGameObjects[i].SetActive( false );
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
				if( !gameStarted )
				{
					playerOrientations[i] = orientation;
					playerIDs[i] = uniqueIdentifier;
					playerGameObjects[i].SetActive(true);
					playerAppearParticles[i].Play();
					audio.playYayay();
					
					GameObject player = playerGameObjects[i];
					MeshRenderer renderer = player.transform.Find( "AnimatedSprite" ).GetComponent<MeshRenderer>();
					renderer.material = materialNormal;
				}
				return;
			}
		}		    	
    }
}


