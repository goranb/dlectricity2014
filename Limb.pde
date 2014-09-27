

class Limb {

	PVector start, end;
	Limb parent;
	String name;

    Limb(String name, PVector start, PVector end, Limb parent){
    	this(name, start, end);
    	this.parent = parent;
	}

	Limb(String name, PVector start, PVector end){
		this.name = name;
		this.start = start;
    	this.end = end;
    	//println("INIT: ", start, end);
	}

}