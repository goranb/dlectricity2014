
class Channel {
	
	int channel;
	float value = 0;
	float damper = 0.75;
	float power = 4;

	Channel(int channel){
		this.channel = channel;
	}

	void update(float input){
		input = pow(min(input, 100.0) / 100.0, power) * 100;
		if (input > value){
			value = input; 
		}
	}

	void draw(float x, float y, float w, float h){
		pushStyle();
		strokeWeight(1);
		stroke(128);
		noFill();
		rect(x, y, w, h);
		noStroke();
		switch(channel){
			case 1:
				fill(255, 0, 0);
				break;
			case 2:
				fill(0, 255, 0);
				break;
			case 3:
				fill(0, 0, 255);
				break;
		}
		rect(x, y + ((100.0 - value) / 100.0) * h, w, (value / 100.0) * h);
		//textSize(32);
		//fill(255);
		//text(round(value), x, y);
		popStyle();
	}

	void send(){

		serial.write(channel + "c" + round(value) + "w");
		//println(channel + "c ::: " + round(value) + "w");
	}

	void tick(){
		value *= damper;
	}
}