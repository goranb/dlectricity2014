

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

    ArrayList<Speed> speeds;

    float damp = 0.75; // damping

	ArrayList<PVector> points;
	ArrayList<Limb> limbs;

	boolean wiggle = false;

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

		Limb left_arm = new Limb("left_arm", left_shoulder, left_elbow);
		limbs.add(left_arm);
		limbs.add(new Limb("left_hand", left_elbow, left_hand, left_arm));
		
		Limb right_arm = new Limb("right_arm", right_shoulder, right_elbow);
		limbs.add(right_arm);
		limbs.add(new Limb("right_hand", right_elbow, right_hand, right_arm));

		Limb left_thigh = new Limb("left_thigh", left_hip, left_knee);
		limbs.add(left_thigh);
		limbs.add(new Limb("left_foot", left_knee, left_foot, left_thigh));

		Limb right_thigh = new Limb("right_thigh", right_hip, right_knee);
		limbs.add(right_thigh);
		limbs.add(new Limb("right_foot", right_knee, right_foot, right_thigh));

		// speeds
        speeds = new ArrayList<Speed>();
        speeds.add(new Speed(left_elbow, left_hand, 1, 10000));
        speeds.add(new Speed(right_elbow, right_hand, 2, 10000));
        //speeds.add(new Speed(right_shoulder, right_elbow, 3, 1000));
	}

	void draw(){
		draw(color(255,0,255, 64));
	}

	void draw(color c){

		wiggle(limbs); // wiggle the test case

		pushMatrix();
		//scale(-1.0, -1.0, -1.0); // flip Y	
		drawLines();
        drawSpeeds();
		popMatrix();
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
        for(Speed speed : speeds){
            pushMatrix();
            //translate(speed.origin.x, speed.origin.y, speed.origin.z);
            translate(speed.ray.x, speed.ray.y, speed.ray.z);
            box(speed.speed);
            popMatrix();
        }
        popStyle();
    }

	void rig(ArrayList<PVector> rig){
		
		for(int i = 0; i < rig.size(); i++){
			PVector from = rig.get(i);
			PVector to = points.get(i);
			to.set(from);
		}
        for(Speed speed : speeds){
            speed.tick();
        }
	}

	void drawLine(PVector v1, PVector v2){
		line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
	}

	void wiggle(ArrayList<Limb> limbs){
		
		// skip if wiggle is not turned on
		if (!wiggle) return;

		//println("--------limbs--------");
		// process limbs
		for(Limb limb : limbs){
			//if (limb.parent == null) continue;
			PVector l = PVector.sub(limb.end, limb.start);
			float m = l.mag();
			//println(limb.name + " : " + m);
			PVector r = PVector.random3D();
			r.setMag(m);
			l.lerp(r, 0.1);
			l.setMag(m);
			PVector oldEnd = new PVector(limb.end.x, limb.end.y, limb.end.z);
			limb.end.set(PVector.add(limb.start, l));
			for(Limb limbChild : limbs){
				if (limbChild.parent == limb){
					limbChild.end.add(PVector.sub(limbChild.start, oldEnd));
					//limbChild.start.set(limb.end);
				}
			}
		}
	}

}