// Line comment.
/* Block comment. */

#version 3.7;
#include "colors.inc"
#declare Accent = <0.15, 0.45, 0.85>;
#declare Radius = 1.25;

camera {
  location <0, 2, -5>
  look_at <0, 1, 0>
}

light_source { <2, 4, -3> color White }

sphere {
  <0, 1, 0>, Radius
  pigment { color rgb Accent }
  finish { phong 0.8 reflection 0.1 }
}

#if (Radius > 0)
  #debug concat("radius=", str(Radius, 0, 2), "\n")
#end

#not_a_valid_directive "intentional error"
