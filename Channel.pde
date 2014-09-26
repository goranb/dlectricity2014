
class Channel {
	
	int channel;
	float value = 0;
	float damper = 0.9;

	Channel(int channel){
		this.channel = channel;
	}

	void update(float val){
		if (val > value){
			value = min(val, 100.0);
		}
	}

	void draw(float x, float y, float w, float h){
		pushStyle();
		noStroke();
		fill(128, 128);
		rect(x, y, w, h);
		fill(255, 128);
		rect(x, y + ((100.0 - value) / 100.0) * h, w, (value / 100.0) * h);
		textSize(32);
		fill(0);
		text(value, x, y);
		popStyle();
	}

	void send(){
		serial.write(channel + "c" + round(value) + "w");
	}

	void tick(){
		value *= damper;
	}
}