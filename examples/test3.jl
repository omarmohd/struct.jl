using LinearAlgebraicRepresentation
L = LinearAlgebraicRepresentation
using ViewerGL
GL = ViewerGL

cylndr = L.rod(.06, .5, 2*pi)([8,1])
chairTop = Struct([t(0,0,0.5),s(0.5,0.5,0.04), cube ])
chairLeg = Struct([t(-.22,-.22,0),s(.5,.5,1),r(0,0,pi/8), cylndr ])
chairlegs = Struct( repeat([ chairLeg,r(0,0,pi/2) ],outer=4) );
chair = Struct([ chairTop, chairlegs ]);
chair = struct2lar(chair)
GL.VIEW([ GL.GLPol(chair..., GL.Point4d(1,1,1,0.2)) ]);
