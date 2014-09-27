

class Person {

	PVector head, 
			neck,
			left_shoulder,
			left_elbow,
			left_hand,
			right_shoulder,
			right_elbow,
			right_hand,
			torso,
			left_hip,
			left_knee,
			left_foot,
			right_hip,
			right_knee,
			right_foot;

	int id;

    ArrayList<DMX> dmxs;

    float damp = 0.75; // damping

	ArrayList<PVector> points;
	ArrayList<Limb> limbs;

	boolean active = false;

	Person(int id){
        // save id
        this.id = id;
		// init points
		head = new PVector(0, -80, 0 - width / 2);
		neck = new PVector(0, -55, 0 - width / 2);
		left_shoulder = new PVector(20, -50, -width / 2);
		left_elbow = new PVector(25, -20, -10 - width / 2);
		left_hand = new PVector(30, 10, 0 - width / 2);
		right_shoulder = new PVector(-20, -50, 0 - width / 2);
		right_elbow = new PVector(-25, -20, -10 - width / 2);
		right_hand = new PVector(-30, 10, 0 - width / 2);
		torso = new PVector(0, -30, 0 - width / 2);
		left_hip = new PVector(10, 0, 0 - width / 2);
		left_knee = new PVector(15, 30, 10 - width / 2);
		left_foot = new PVector(20, 60, 0 - width / 2);
		right_hip = new PVector(-10, 0, 0 - width / 2);
		right_knee = new PVector(-15, 30, 10 - width / 2);
		right_foot = new PVector(-20, 60, 0 - width / 2);
        // group them
		points = new ArrayList<PVector>();
		points.add(head);
		points.add(neck);
		points.add(left_shoulder);
		points.add(left_elbow);
		points.add(left_hand);
		points.add(right_shoulder);
		points.add(right_elbow);
		points.add(right_hand);
		points.add(torso);
		points.add(left_hip);
		points.add(left_knee);
		points.add(left_foot);
		points.add(right_hip);
		points.add(right_knee);
		points.add(right_foot);

		limbs = new ArrayList<Limb>();
		limbs.add(new Limb("head", neck, head));

		Limb l_left_arm = new Limb("left_arm", left_shoulder, left_elbow);
		limbs.add(l_left_arm);
		Limb l_left_hand = new Limb("left_hand", left_elbow, left_hand, l_left_arm);
		limbs.add(l_left_hand);
		
		Limb l_right_arm = new Limb("right_arm", right_shoulder, right_elbow);
		limbs.add(l_right_arm);
		Limb l_right_hand = new Limb("right_hand", right_elbow, right_hand, l_right_arm);
		limbs.add(l_right_hand);

		Limb l_left_thigh = new Limb("left_thigh", left_hip, left_knee);
		limbs.add(l_left_thigh);
		Limb l_left_foot = new Limb("left_foot", left_knee, left_foot, l_left_thigh);
		limbs.add(l_left_foot);

		Limb l_right_thigh = new Limb("l_right_thigh", right_hip, right_knee);
		limbs.add(l_right_thigh);
		Limb l_right_foot = new Limb("right_foot", right_knee, right_foot, l_right_thigh);
		limbs.add(l_right_foot);

		// speeds
        dmxs = new ArrayList<DMX>();
        dmxs.add(new DMX(l_left_hand, channels.get(3), 200));
        dmxs.add(new DMX(l_right_hand, channels.get(1), 200));
        //dmxs.add(new DMX(l_left_arm, channels.get(4)));
        //dmxs.add(new DMX(l_right_arm, channels.get(4)));
        dmxs.add(new DMX(l_left_foot, channels.get(2), 300));
        dmxs.add(new DMX(l_right_foot, channels.get(2), 300));
        //dmxs.add(new DMX(l_left_thigh, channels.get(4)));
        //dmxs.add(new DMX(l_right_thigh, channels.get(4)));
        //speeds.add(new Speed(right_shoulder, right_elbow, 3, 1000));
	}

	void draw(){
		draw(color(255,0,255, 64));
	}

	void draw(color c){
		if (active){
			pushMatrix();
			scale(-1.0, 1.0, 1.0); // flip Y	
			drawLines();
	        drawSpeeds();
			popMatrix();
		}
	}

	void drawJoints(){
		pushStyle();
		fill(0, 0, 255);
		noStroke();
		for (PVector p : points){
			pushMatrix();
			translate(p.x, p.y, p.z);
			box(20);
			popMatrix();
		}
		popStyle();
	}

	void drawLines(){
		pushStyle();
		noFill();
		stroke(0,255,0);
		strokeWeight(2);
		drawLine(head, neck);
		drawLine(neck, left_shoulder);
		drawLine(left_shoulder, left_elbow);
		drawLine(left_elbow, left_hand);
		drawLine(neck, right_shoulder);
		drawLine(right_shoulder, right_elbow);
		drawLine(right_elbow, right_hand);
		drawLine(left_shoulder, torso);
		drawLine(right_shoulder, torso);
		drawLine(torso, left_hip);
		drawLine(left_hip, left_knee);
		drawLine(left_knee, left_foot);
		drawLine(torso, right_hip);
		drawLine(right_hip, right_knee);
		drawLine(right_knee, right_foot);
		popStyle();
	}

    void drawSpeeds(){
        pushStyle();
        noStroke();
        fill(0,255,0);
        for(DMX dmx : dmxs){
            pushMatrix();
            //translate(speed.origin.x, speed.origin.y, speed.origin.z);
            translate(dmx.limb.end.x, dmx.limb.end.y, dmx.limb.end.z);
            ellipseMode(CENTER);
            ellipse(0, 0, dmx.speed, dmx.speed);
            //box(dmx.speed);
            popMatrix();
        }
        popStyle();
    }

	void rig(ArrayList<PVector> rig){
		
		boolean difference = false;
		float tolerance = 0.01;

		for(int i = 0; i < rig.size(); i++){
			PVector from = rig.get(i);
			PVector to = points.get(i);
			PVector diff = PVector.sub(to, from);
			if (diff.mag() > tolerance){
				difference = true;
			}
			to.set(from);
		}
		if (difference){
			for(DMX dmx : dmxs){
	            dmx.tick();
	        }
	        active = true;
		} else {
			active = false;
		}
	}

	void drawLine(PVector v1, PVector v2){
		line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
	}

}