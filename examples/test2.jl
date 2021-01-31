using ViewerGL
GL = ViewerGL

refectory = Struct(repeat([singleRow,t(3,0,0)],outer=10));
refectory = struct2lar(refectory)
GL.VIEW([ GL.GLPol(refectory..., GL.Point4d(1,1,1,0.2)) ]);
