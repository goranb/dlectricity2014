
class DMX {

	float damper = 0.5;

	float speed = 0.0;
	float angle = 0.0;
	Limb limb;
	int channel;
	float factor;

	DMX(Limb limb, int channel, float factor){
		this.limb = limb;
		this.channel = channel;
		this.factor = factor;
	}

	DMX(Limb limb, int channel){
		this(limb, channel, 1000);
	}

	void tick(){
		float newAngle = PVector.angleBetween(limb.start, PVector.sub(limb.end, limb.start));
		speed = speed + (abs(newAngle - angle) * factor - speed) * damper; // degs?
		angle = newAngle;
		//println("Speed: " + speed);
	}

	void init(){
		angle = PVector.angleBetween(limb.start, PVector.sub(limb.end, limb.start));
	}

}