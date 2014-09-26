
import SimpleOpenNI.*;
import processing.serial.*;

Serial serial = null; 

SimpleOpenNI context;

boolean depthImage = false,
		skeleton = false,
		characters = true;

int testDepth = 0;

ArrayList<Person> people = new ArrayList<Person>();
ArrayList<Channel> channels = new ArrayList<Channel>();
int channelNum = 10;

void setup()
{
	size(640, 480, P3D);
	context = new SimpleOpenNI(this);

	if(context.isInit() == false){
		println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
		exit();
		return;
	} else {

		// enable depthMap generation (?)
		context.enableDepth();
		 
		// enable skeleton generation for all joints
		context.enableUser();
	}
 
	background(0);
	smooth();

	// set up camera
	float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
	float near = cameraZ / 10.0;
	float far = cameraZ * 10.0;
	// println("CameraZ: " + cameraZ);	
	// println("Near: " + near);
	// println("Far: " + far);	
	perspective(PI / 3.0, width * 1.0 / height, near, far);

	// setup serial

	String[] serials = Serial.list();
	println(serials);
	for(String device : serials){
		//if (device.equals("/dev/tty.usbserial-A800eIqH")){
		if (device.equals("/dev/ttyUSB0")){ // ubuntu	
			serial = new Serial(this, device, 9600);
		}
	}

	// first person
	/*
	Person test = new Person(0);
	test.wiggle = true;
	people.add(test);
	*/

	// setup channels
	for(int i = 0; i < channelNum; i++){
		channels.add(new Channel(i));
	}
}

void draw()
{
	background(0);
	//directionalLight(255, 255, 255, 0, 0, -1);
	
	// update the cam
	context.update();

	// dept image
	if (depthImage && context.isInit()){
		pushMatrix();
		translate(width, 0);
		scale(-1, 1, 1); // mirror image
		image(context.userImage(), 0, 0, width, height);
		popMatrix();
	}


	pushMatrix();
	translate(width / 2, height / 2);

	// skeletons start
	pushMatrix();						
	
	// draw the skeleton if it's available
	int[] userList = context.getUsers();

	// correction for the skeleton
	translate(width / 2, -height / 2);
	scale(-2, 2, 2);

	if (userList.length > 0){
		for(int i=0; i < userList.length; i++){
			if(context.isTrackingSkeleton(userList[i])){

				int userId = userList[i];
				if (skeleton) drawSkeleton(userId);

				PVector head = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_HEAD, head);
				PVector neck = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK, neck);

				PVector left_shoulder = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER, left_shoulder);
				PVector left_elbow = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW, left_elbow);
				PVector left_hand = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND, left_hand);
			 
				PVector right_shoulder = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER, right_shoulder);
				PVector right_elbow = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW, right_elbow);
				PVector right_hand = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND, right_hand);

				PVector torso = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_TORSO, torso);

				PVector left_hip = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HIP, left_hip);
				PVector left_knee = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_KNEE, left_knee);
				PVector left_foot = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_FOOT, left_foot);

				PVector right_hip = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP, right_hip);
				PVector right_knee = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_KNEE, right_knee);
				PVector right_foot = new PVector();
				context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_FOOT, right_foot);

				
				ArrayList<PVector> points = new ArrayList<PVector>();
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
				for (PVector p : points){
					p.x = -p.x;
					p.y = -p.y; // already flipped?
					p.z = -p.z;
				}

				// apply rig to person
				for(Person person : people){
					if (person.id == userId){
						person.rig(points);
					}
				}
			}			
		}
	}

	popMatrix();
	// end skeletons

	// people
	pushMatrix();
	//scale(1, 1, 1);
	translate(0, 0, width);
	for(Person person : people){
		person.draw();
	}
	popMatrix();
	// end people

	// test box
	// pushStyle();
	// noStroke();
	// fill(0, 255, 255);
	// box(20);
	// popStyle();
	// end test box

	// draw and send to channels
	float step = width / channelNum;
	for(int i = 1; i < channelNum; i++){
		Channel c = channels.get(i);
		c.draw(- width / 2 + step * i, height / 4, step, height / 4);
		c.send();
		c.tick();
	}

	popMatrix();
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId){
	
	pushStyle();
	noFill();
	stroke(255);
	strokeWeight(5);
	pushMatrix();
	//line(0, 0, width, height);

	context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

	context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
	context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
	context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

	context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
	context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
	context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

	context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
	context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

	context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
	context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
	context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

	context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
	context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
	context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);	

	popMatrix();
	popStyle();
}


// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
	println("\t+ NEW: " + userId);	
	curContext.startTrackingSkeleton(userId);
	people.add(new Person(userId));
}

void onLostUser(SimpleOpenNI curContext, int userId)
{
	println("\t- DIED: " + userId);
	for(Person person : people){
		if (person.id == userId){
			people.remove(person);		
		}
	}
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
	//println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
	switch(key){
		case ' ':
			if (context.isInit()){
				context.setMirror(!context.mirror());
				println("mirror: " + context.mirror());
			}
			break;
		case 'D':
		case 'd':
			depthImage = !depthImage;
			break;
		case 'S':
		case 's':
			skeleton = !skeleton;
			break;
		case 'C':
		case 'c':
			characters = !characters;
			break;
		case '+':
		case '=':
			testDepth += 10;
			println(testDepth);
			break;
		case '_':
		case '-':
			testDepth -= 10;
			println(testDepth);
			break;
	}
}	
	
