using UnityEngine;
using System.Collections;

public class HHGameLoop : MonoBehaviour {

	public GameObject TimerLabel;
	
	private float timerMax = 11.0f;
	private float timer = 0.0f;

	public ParticleSystem TimerParticle;
	public ParticleSystem TimerParticleEnd;
	
	// Use this for initialization
	void Start () {
		timer = timerMax;
		TimerParticle.Play();
	}
	
	// Update is called once per frame
	void Update () {

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
}
