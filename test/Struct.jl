using Test
using LinearAlgebra
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

@testset "2D" begin
	square = ([[0.; 0] [0; 1] [1; 0] [1; 1]], [[1, 2, 3,
			4]], [[1,2], [1,3], [2,4], [3,4]])
	@testset "apply Translation 2D" begin
		@test typeof(apply(t(-0.5,-0.5),square))==Tuple{Array{Float64,2},Array{Array{Int64,1},1},Array{Array{Int64,1},1}}
		@test apply(t(-0.5,-0.5),square)==([-0.5 -0.5 0.5 0.5; -0.5 0.5 -0.5 0.5], Array{Int64,1}[[1, 2, 3, 4]], Array{Int64,1}[[1, 2], [1, 3], [2, 4], [3, 4]])
	end
	@testset "apply Scaling 2D" begin
		@test typeof(apply(s(-0.5,-0.5),square))==Tuple{Array{Float64,2},Array{Array{Int64,1},1},Array{Array{Int64,1},1}}
		@test apply(s(-0.5,-0.5),square)==([0.0 0.0 -0.5 -0.5; 0.0 -0.5 0.0 -0.5], Array{Int64,1}[[1, 2, 3, 4]], Array{Int64,1}[[1, 2], [1, 3], [2, 4], [3, 4]])
	end
	@testset "apply Rotation 2D" begin
		@test typeof(apply(r(0),square))==Tuple{Array{Float64,2},Array{Array{Int64,1},1},Array{Array{Int64,1},1}}
		@test apply(r(0),square)==([0.0 0.0 1.0 1.0; 0.0 1.0 0.0 1.0], Array{Int64,1}[[1, 2, 3, 4]], Array{Int64,1}[[1, 2], [1, 3], [2, 4], [3, 4]])
	end
end

@testset "3D" begin
	cube=Lar.cuboid([1,1,1])
	@testset "apply Translation 3D" begin
		@test typeof(apply(t(-0.5,-0.5,-0.5),cube))==Tuple{Array{Float64,2},Array{Array{Int64,1},1}}
		@test apply(t(-0.5, -0.5, -0.5),cube) ==
		([-0.5 -0.5 -0.5 -0.5 0.5 0.5 0.5 0.5;
		-0.5 -0.5 0.5 0.5 -0.5 -0.5 0.5 0.5; -0.5 0.5 -0.5 0.5 -0.5 0.5 -0.5 0.5],
		Array{Int64,1}[[1, 2, 3, 4, 5, 6, 7, 8]])
	end
	@testset "apply Scaling 3D" begin
		@test typeof(apply(s(-0.5,-0.5,-0.5),cube))==
		Tuple{Array{Float64,2},Array{Array{Int64,1},1}}
		@test apply(s(-0.5, -0.5, -0.5),cube) ==
		([0.0 0.0 0.0 0.0 -0.5 -0.5 -0.5 -0.5;
		0.0 0.0 -0.5 -0.5 0.0 0.0 -0.5 -0.5; 0.0 -0.5 0.0 -0.5 0.0 -0.5 0.0 -0.5],
		Array{Int64,1}[[1, 2, 3, 4, 5, 6, 7, 8]])
	end
	@testset "apply Rotation 3D" begin
		@test typeof(apply(r(pi,0,0),cube))==
		Tuple{Array{Float64,2},Array{Array{Int64,1},1}}
		@test apply(r(0, 0, 0),cube) ==
		 ([0.0 0.0 0.0 0.0 1.0 1.0 1.0 1.0; 0.0 0.0 1.0 1.0 0.0 0.0 1.0 1.0;
		 0.0 1.0 0.0 1.0 0.0 1.0 0.0 1.0], Array{Int64,1}[[1, 2, 3, 4, 5, 6, 7, 8]])
	end
end

@testset "removeDups Tests" begin
	CW1=[[0,1,2,3],[4,5,6,7],[0,1,4,5],[2,3,6,7],[0,2,4,6],[1,3,5,7],
		 [4,5,6,7],[8,9,10,11],[4,5,8,9],[6,7,10,11],[4,6,8,10],[5,7,9,11]]
	CW2=[[0,1,2,3],[4,5,6,7],[8,9,10,11],[12,13,14,15],[16,17,18,19]]
	@testset "removeDups 3D" begin
		@test length(removeDups(CW1))<= length(CW1)
		@test typeof(removeDups(CW1))==Array{Array{Int64,1},1}
	end
	@testset "removeDups 2D" begin
		@test length(removeDups(CW2))<= length(CW2)
		@test typeof(removeDups(CW2))==Array{Array{Int64,1},1}
	end
end

@testset "Struct Tests" begin
	square=Lar.cuboid([1,1])
	@test Struct([square]).body==[square]
	@test Struct([square]).dim==size(square[1],1)
	@test Struct([square]).body[1]==square
end

@testset "struct2lar" begin
   @testset "struct2lar 2D" begin
      square = Lar.cuboid([1,1])
      table = apply(t(-0.5,-0.5),square)
      structure = Struct([repeat([table,r(pi/2)],outer=2)...])
      @test typeof(struct2lar(structure))==
      		Tuple{Array{Float64,2},Array{Array{Int64,1},1}}
	  @test size(struct2lar(structure)[1])==(2, 4)
   end
   @testset "struct2lar 3D" begin
      BV = [[1,2,3,4],[5,6,7,8],[1,2,5,6],[3,4,7,8],[1,3,5,7],[2,4,6,8]]
      V = hcat([[0.0,0.0,0.0],[0.0,0.0,1.0],[0.0,1.0,0.0],[0.0,1.0,1.0],
      [1.0,0.0,0.0],[1.0,0.0,1.0],[1.0,1.0,0.0],[1.0,1.0,1.0]]...)
      block = (V,BV)
      structure = Struct(repeat([block,t(1,0,0)],outer=2));
      @test typeof(struct2lar(structure))==
      	Tuple{Array{Float64,2},Array{Array{Int64,1},1}}
      @test size(struct2lar(structure)[1],1)==3
    end
end

@testset "embedTraversal Tests" begin
	square = Lar.cuboid([1,1])
	x = Struct([square])

	table = apply(t(-0.5,-0.5),square)
	structure = Struct([repeat([table,r(pi/2)],outer=2)...])

	@testset "embedTraversal Tests tuple body" begin
		@test typeof(embedTraversal(Struct(),deepcopy(x),1,"New"))==Struct
		#l'unico elemento del body di x è una tupla, viene eseguita la funzione embedTraversalTupleOrArray
		@test typeof(embedTraversal(Struct(),deepcopy(x),1,"New").body[1][1])==Tuple{Matrix{Float64},Array{Array{Int64,1},1}}

		# in questi tre casi n=1, n=2 e n=3, ma in generale:
		# length(embedTraversal(Struct(),x,n,"New").body[1][1][1])=length(x.body[1][1])+4*n
		@test length(embedTraversal(Struct(),deepcopy(x),1,"New").body[1][1][1])==length(x.body[1][1])+4*1
		@test length(embedTraversal(Struct(),deepcopy(x),2,"New").body[1][1][1])==length(x.body[1][1])+4*2
		@test length(embedTraversal(Struct(),deepcopy(x),3,"New").body[1][1][1])==length(x.body[1][1])+4*3
	end

	@testset "embedTraversal Tests matrix body" begin
		@test typeof(embedTraversal(Struct(),deepcopy(structure),1,"New"))==Struct
		#il primo elemento del body di structure è una tupla, viene eseguita la funzione embedTraversalTupleOrArray
		@test typeof(embedTraversal(Struct(),deepcopy(structure),1,"New").body[1][1])==Tuple{Matrix{Float64},Array{Array{Int64,1},1}}
		#il secondo elemento del body di structure è una matrice, viene eseguita la funzione embedTraversalMatrix
		@test typeof(embedTraversal(Struct(),deepcopy(structure),1,"New").body[2][1])==Matrix{Float64}

		# in questi tre casi n=1, n=2 e n=3, ma in generale:
		# length(embedTraversal(Struct(),x,n,"New").body[1][1][1])=length(x.body[1][1])+4*n
		@test length(embedTraversal(Struct(),deepcopy(structure),1,"New").body[1][1][1])==length(structure.body[1][1])+4*1
		@test length(embedTraversal(Struct(),deepcopy(structure),2,"New").body[1][1][1])==length(structure.body[1][1])+4*2
		@test length(embedTraversal(Struct(),deepcopy(structure),3,"New").body[1][1][1])==length(structure.body[1][1])+4*3

		# in questi quattro casi n=1, n=2, n=3 e n=4, ma in generale:
		# length(embedTraversal(Struct(),x,n,"New").body[2][1])=length(x.body[2])+((6+n)*n)
		@test length(embedTraversal(Struct(),deepcopy(structure),1,"New").body[2][1])==length(structure.body[2])+7*1
		@test length(embedTraversal(Struct(),deepcopy(structure),2,"New").body[2][1])==length(structure.body[2])+8*2
		@test length(embedTraversal(Struct(),deepcopy(structure),3,"New").body[2][1])==length(structure.body[2])+9*3
		@test length(embedTraversal(Struct(),deepcopy(structure),4,"New").body[2][1])==length(structure.body[2])+10*4

		# la dimensione della matrice nel body aumenta di n, in questo caso n=2, ma in generale:
		# size(embedTraversal(Struct(),x,n,"New").body[indiceMatrice][1])=
		# (size(structure.body[indiceMatrice])[1]+n,size(structure.body[indiceMatrice])[2]+n)
		@test size(embedTraversal(Struct(),deepcopy(structure),2,"New").body[2][1])==
		(size(structure.body[2])[1]+2,size(structure.body[2])[2]+2)
	end
end


@testset "checkStruct" begin
	square=[([[0.575;-0.175] [0.575;0.175] [0.925;-0.175] [0.925;0.175]],
	[[0,1,2,3]])]
	@test checkStruct(square)==length(square[1][1][:,1])
	@test checkStruct(square)==2
end

@testset "cuboid Tests" begin
	square=Lar.cuboid([1,1])
	cube=Lar.cuboid([1,1,1])
	@testset "cuboid Tests 2D" begin
		@test typeof(square)==Tuple{Array{Float64,2},Array{Array{Int64,1},1}}
		@test length(square)==2
		@test size(square[1])==(2, 4)
	end
	@testset "cuboid Tests 3D" begin
		@test typeof(cube)==Tuple{Array{Float64,2},Array{Array{Int64,1},1}}
		@test length(cube)==2
		@test size(cube[1])==(3, 8)
	end
end

@testset "traversal" begin
	square=Lar.cuboid([1,1])
	dim = 2
	structure=Struct([square])
	@test typeof(structure.body) ==
	Array{Tuple{Array{Float64,2},Array{Array{Int64,1},1}},1}
	@test length(traversal(Matrix{Float64}(LinearAlgebra.I, dim+1, dim+1),[],structure,[]))==length(structure.body)
	@test typeof(traversal(Matrix{Float64}(LinearAlgebra.I, dim+1, dim+1),[],structure,[]))==Array{Any,1}
end

@testset "embedStruct Tests" begin
	square = Lar.cuboid([1,1])
	x = Lar.Struct([square])
	suffix="-New"

	@test typeof(embedStruc(1)(deepcopy(x),suffix))==Struct
	@test embedStruc(1)(deepcopy(x),suffix).category==x.category
	@test embedStruc(1)(deepcopy(x),suffix).dim==x.dim+1
	@test embedStruc(3)(deepcopy(x),suffix).dim==x.dim+3
	@test embedStruc(1)(deepcopy(x),suffix).box[1][1]==x.box

	# in questo caso n=2, dove n è la lunghezza del primo elemento del box di x,
	# in generale: embedStruc(0)(x,suffix)[2]=n
	@test embedStruc(0)(deepcopy(x),suffix)[2]==2

	# in questi tre casi n=1, n=3 e n=5, ma in generale:
	# length(embedStruct(n)(x,suffix).body[1][1][1])=length(x.body[1][1])+4*n
	@test length(embedStruc(1)(deepcopy(x),suffix).body[1][1][1])==length(x.body[1][1])+4*1
	@test length(embedStruc(3)(deepcopy(x),suffix).body[1][1][1])==length(x.body[1][1])+4*3
	@test length(embedStruc(5)(deepcopy(x),suffix).body[1][1][1])==length(x.body[1][1])+4*5
end
