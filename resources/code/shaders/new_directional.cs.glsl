#version 430

layout(local_size_x = 8, local_size_y = 8, local_size_z = 8) in; //3d workgroup

uniform layout(rgba8) image3D current;
uniform layout(r8) image3D lighting;

uniform float utheta;
uniform float uphi;

uniform float light_dim;
uniform float light_intensity;

uniform float decay_power;

// this refit of the directional lighting function is going to be the basis for the point light function
// the goal is to reduce the artifacts that come from the regular spacing of the 2d grid ('lightmap') causing 
// weird aliasing when they hit the different faces of the voxel block.



//thanks to Neil Mendoza via http://www.neilmendoza.com/glsl-rotation-about-an-arbitrary-axis/
mat3 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

double tmin, tmax; //global scope, set in hit() to tell min and max parameters

#define NUM_STEPS 500
#define MIN_DISTANCE 0.0
#define MAX_DISTANCE 10.0

bool hit(vec3 org, vec3 dir)
{
  // hit() code adapted from:
  //
  //    Amy Williams, Steve Barrus, R. Keith Morley, and Peter Shirley
  //    "An Efficient and Robust Ray-Box Intersection Algorithm"
  //    Journal of graphics tools, 10(1):49-54, 2005

  //the bounding box
  vec3 min = vec3(-1,-1,-1);
  vec3 max = vec3(1,1,1);

  int sign[3];

  vec3 inv_direction = vec3(1/dir.x, 1/dir.y, 1/dir.z);

  sign[0] = (inv_direction[0] < 0)?1:0;
  sign[1] = (inv_direction[1] < 0)?1:0;
  sign[2] = (inv_direction[2] < 0)?1:0;

  vec3 bbox[2] = {min,max};

  tmin = (bbox[sign[0]][0] - org[0]) * inv_direction[0];
  tmax = (bbox[1-sign[0]][0] - org[0]) * inv_direction[0];

  double tymin = (bbox[sign[1]][1] - org[1]) * inv_direction[1];
  double tymax = (bbox[1-sign[1]][1] - org[1]) * inv_direction[1];

  if ( (tmin > tymax) || (tymin > tmax) )
    return false;
  if (tymin > tmin)
    tmin = tymin;
  if (tymax < tmax)
    tmax = tymax;

  double tzmin = (bbox[sign[2]][2] - org[2]) * inv_direction[2];
  double tzmax = (bbox[1-sign[2]][2] - org[2]) * inv_direction[2];

  if ( (tmin > tzmax) || (tzmin > tmax) )
    return false;
  if (tzmin > tmin)
    tmin = tzmin;
  if (tzmax < tmax)
    tmax = tzmax;
  return ( (tmin < MAX_DISTANCE) && (tmax > MIN_DISTANCE) );

  return true;
}


void traceray(vec3 dir)
{
	// the location you need to consider is specified by gl_GlobalInvocationID

	


    vec3 org = (vec3(imageSize(lighting))/2.0f) *



  // float current_t = float(tmin);
  // float intensity = light_intensity; //initialize ray intensity

  // float step = float((tmax-tmin))/NUM_STEPS;
  // if(step < 0.001f) step = 0.001f;

  // ivec3 sample_location = ivec3((vec3(imageSize(lighting))/2.0f)*(org+current_t*dir+vec3(1)));

  // vec4 new_color_read = imageLoad(current, sample_location);
  // vec4 new_light_read = imageLoad(lighting, sample_location);

  // //three termination conditions - number of steps, distance along the ray, intensity < 0
  // for(int i = 0; i < NUM_STEPS; i++)
  // {
  //   if(current_t <= tmax && intensity > 0)
  //   {
  //       imageStore(lighting, sample_location, vec4(new_light_read.r+intensity));

  //       //intensity -= new_color_read.a;
  //       //intensity *= 1-pow(new_color_read.a, 2);
  //       intensity *= 1-pow(new_color_read.a, decay_power);

  //       current_t += step;
  //       sample_location = ivec3((vec3(imageSize(lighting))/2.0f)*(org+current_t*dir+vec3(1)));

  //       new_color_read = imageLoad(current, sample_location);
  //       new_light_read = imageLoad(lighting, sample_location);
  //   }
  // }
}


void main()
{

	// dir calculation is the same as the old directional lighting shader, which is in turn the same as the display shader
    vec3 dir = vec3(   0,    0, -2); //simply a vector pointing in the opposite direction, no xy offsets

    // rotate dir vector 'up' by phi, e.g. about the x axis
    mat3 rotphi = rotationMatrix(vec3(1,0,0), uphi);
    dir *= rotphi;

    // rotate about the y axis by theta
    mat3 rottheta = rotationMatrix(vec3(0,1,0), utheta);
    dir *= rottheta;

	 // this is all the information traceray needs, the direction from which the light is coming
	 traceray(dir);
}

