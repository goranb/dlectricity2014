
class Speed {

	float damper = 0.2;

	float speed = 0.0;
	float angle = 0.0;
	PVector origin;
	PVector ray;
	int channel;
	float factor;

	Speed(PVector origin, PVector ray, int channel, float factor){
		this.origin = origin;
		this.ray = ray;
		this.channel = channel;
		this.factor = factor;
	}

	Speed(PVector origin, PVector ray, int channel){
		this(origin, ray, channel, 1.0);
	}

	void tick(){
		float newAngle = PVector.angleBetween(origin, PVector.sub(ray, origin));
		speed = speed + (abs(newAngle - angle) * factor * damper - speed); // degs?
		angle = newAngle;
		//println("Speed: " + speed);
	}

}