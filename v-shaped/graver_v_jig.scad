//changeable values
s_elevation = 20;
s_stickout = 30;
alpha = 45;
beta = 105;
theta = 8;
rampa_opening = 6;

assert(alpha >= 10 && alpha <= 60, "Alpha has to be between 10 and 80 degrees");
assert(beta >= 30 && beta <= 180, "Beta has to be between 30 and 180 degrees");
assert(theta >= 2 && theta <= 20, "Theta has to be between 2 and 20 degrees");

assert(s_stickout >= 0 && s_stickout <= 100, "Stickout has to be between 0 and 100");
assert(s_elevation >= 0 && s_elevation <= 100, "Elevation has to be between 0 and 100");
assert(rampa_opening >= 3 && rampa_opening <= 8, "Opening for screw has to be between 3 and 8");

//fixed values
width = 50;
thickness = 5;
workpiece_hole_diameter = 12.2;
workpiece_holder_height = 20;
marking_font = "Liberation Sans";


left = -width / 2;
right = +width / 2;

h1 = (s_stickout * sin(alpha) + s_elevation) / (cos(alpha));
h2 = (s_stickout * sin(theta) + s_elevation) / (cos(theta) * sin(beta/2));
h3 = h2 - (width / (2 * tan(beta / 2)));
alpha_retract =  thickness / tan(90 - alpha);
theta_retract =  thickness / tan(90 - theta);

echo(str("h1 = ", h1));
echo(str("h2 = ", h2));
echo(str("h3 = ", h3));
echo(str("retract alpha = ", alpha_retract));
echo(str("retract theta = ", theta_retract));

module workpieceHole(height) {
    union(){        
        cylinder(h = height, d = workpiece_hole_diameter, $fn = 60);
        translate([-1.6,0,0])
        cube([3.2,2.6 + workpiece_hole_diameter / 2,height]);
    }    
}

module screwHolder(diameter, length){
    translate([0,0,thickness + workpiece_holder_height - 10])  
    rotate([0,90,0])
    cylinder(h=length, d = diameter, $fn = 60);
}

module markings(markingText) {    
    translate([0,12,thickness-0.4])
    linear_extrude(height=2)
    text(markingText, font=marking_font, halign="center", size=5);
}

module basePlate(){

    //Construct the polygon for the base plate. The graver will sit at [0,0].
    BasePoints = [
        //Front face
        [left,-h3,0],[left,h1,0],[right, h1,0],[right,-h3,0],
        [0,-h2,0],[left,-h3,0],

        //Back face
        [left,-h3 - theta_retract,thickness],[left,h1 + alpha_retract,thickness],[right, h1 + alpha_retract,thickness],[right,-h3 - theta_retract,thickness],
        [0,-h2 - theta_retract,thickness],[left,-h3 - theta_retract, thickness],
    ];

    Faces = [
        [5,4,3,2,1,0],      //Front face 
        [6,7,8,9,10,11],    //Back face 
        
        [0,1,7,6],          //Side faces (ff) 
        [1,2,8,7],
        [2,3,9,8],
        [3,4,10,9],
        [4,5,11,10]
    ];

    difference(){
       polyhedron(points = BasePoints, faces = Faces);              
       workpieceHole(thickness);
       markings(str(alpha, "-", beta , "-", theta));
    }    
}

module workpieceHolder(){
     screw_block = workpiece_hole_diameter / 2 + 5 + 6; 

     difference(){
       union(){
          cylinder(h=workpiece_holder_height + thickness, d = workpiece_hole_diameter + 10);              

          screwHolder(10, screw_block);

          translate([0,-5,0])            
          cube([screw_block,10,thickness + workpiece_holder_height - 10]);

       }  

       screwHolder(rampa_opening, screw_block);
       workpieceHole(workpiece_holder_height + thickness);
    }
}

union(){
    basePlate();
    workpieceHolder();
}


