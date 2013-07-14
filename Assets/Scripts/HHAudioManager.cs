using UnityEngine;
using System.Collections;

public class HHAudioManager : MonoBehaviour {

	private AudioClip[] music;
	
	public AudioClip dance01;
	public AudioClip dance02;
	public AudioClip dance03;
	public AudioClip dance04;
	public AudioClip dance05;
	public AudioClip dance06;
	public AudioClip dance07;
	public AudioClip dance08;
	public AudioClip dance09;
	public AudioClip dance10;
	public AudioClip dance11;
	public AudioClip dance12;
	
	public AudioClip yay;
	public AudioClip yayay;
	public AudioClip bust;
	public AudioClip whistle;
	
	private AudioSource channelA;
	private AudioSource channelB;
	
	// Use this for initialization
	void Start () {
		music = new AudioClip[] {   dance01,
									dance02,
									dance03,
									dance04,
									dance05,
									dance06,
									dance07,
									dance08,
									dance09,
									dance10,
									dance11,
									dance12 };
									
		channelA = gameObject.AddComponent<AudioSource>();
		channelB = gameObject.AddComponent<AudioSource>();
	}
	
	public void randomSong() {
								
		int randomNumber = Random.Range(0,(music.Length - 1));
		channelA.Stop();
		channelA.clip = music[randomNumber];
		channelA.Play();
		
	}
	
	public void playYay() {
		channelB.clip = yay;
		channelB.Play();
	}
	
	public void playYayay() {
		channelB.clip = yayay;
		channelB.Play();	
	}
	
	public void playBust() {
		channelB.clip = bust;
		channelB.Play();	
	}
	
	public void playWhistle() {
		channelB.clip = whistle;
		channelB.Play();
	}
	
	// Update is called once per frame
	void Update () {
	}
}
