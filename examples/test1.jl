using ViewerGL
GL = ViewerGL

theChair = Struct([t(-.8,0,0), chair ])
fourChairs = Struct( repeat([L.r(0,0,pi/2), theChair],outer=4) );
fourSit = Struct([fourChairs,table]);
fourSit = struct2lar(fourSit)
GL.VIEW([ GL.GLPol(fourSit..., GL.Point4d(1,1,1,0.2)) ]);
