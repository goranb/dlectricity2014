
class DMX {

	float damper = 0.5;

	float speed = 0.0;
	float angle = 0.0;
	Limb limb;
	Channel channel;
	float factor;

	DMX(Limb limb, Channel channel, float factor){
		this.limb = limb;
		this.channel = channel;
		this.factor = factor;
	}

	DMX(Limb limb, Channel channel){
		this(limb, channel, 200);
	}

	void tick(){
		float newAngle = PVector.angleBetween(limb.start, PVector.sub(limb.end, limb.start));
		//speed = speed + (abs(newAngle - angle) * factor - speed) * damper; // degs?
		speed = abs(newAngle - angle) * factor;
		angle = newAngle;
		//println("Speed: " + speed);
		channel.update(speed);
	}

	void init(){
		angle = PVector.angleBetween(limb.start, PVector.sub(limb.end, limb.start));
	}

}