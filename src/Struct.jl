using StaticArrays
using LinearAlgebra
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

"""
	t(args::Array{Float64,1}...)::MMatrix
Genera e ritorna una matrice statica “mat” di trasformazione affine(nello specifico di traslazione) in coordinate omogenee.
Questa matrice ha “d + 1” righe e “d + 1” colonne, dove “d” è il numero di parametri nell'array “args” passato come argomento.
# Examples
```julia
julia> t(1,2)			# 2D translation
# return
3×3 Array{Float64,2}:
 1.0  0.0  1.0
 0.0  1.0  2.0
 0.0  0.0  1.0
julia> Lar.t(1.,2,3)		# 3D translation
# return
4×4 Array{Float64,2}:
 1.0  0.0  0.0  1.0
 0.0  1.0  0.0  2.0
 0.0  0.0  1.0  3.0
 0.0  0.0  0.0  1.0
```
"""
function t(args...)
	d = length(args)
	mat = MMatrix{d+1,d+1,Float64}(1I)
	@inbounds for k in range(1, length=d)
        	mat[k,d+1]=args[k]
	end
	return mat
end


"""
	s(args::Array{Float64,1}...)::MMatrix\
Genera e ritorna una matrice statica “mat” di trasformazione affine(di ridimensionamento) in coordinate omogenee.
Questa matrice ha “d + 1” righe e “d + 1” colonne, dove “d” è il numero di parametri nell'array “args” passato come argomento.
# Examples
```julia
julia> Lar.s(2,3)			# 2D scaling
# return
3×3 Array{Float64,2}:
 2.0  0.0  0.0
 0.0  3.0  0.0
 0.0  0.0  1.0
julia> Lar.s(2.,3.,4.)		# 3D scaling
# return
4×4 Array{Float64,2}:
 2.0  0.0  0.0  0.0
 0.0  3.0  0.0  0.0
 0.0  0.0  4.0  0.0
 0.0  0.0  0.0  1.0
```
"""
function s(args...)
	d = length(args)
	mat = MMatrix{d+1,d+1,Float64}(1I)
	@inbounds for k in range(1, length=d)
		mat[k,k]=args[k]
	end
	return mat
end


"""
	r2D(args::Array{Float64,1}...)::Matrix
Genera e ritorna una matrice “mat” di trasformazione affine(di rotazione in 2D) in coordinate omogenee.
Questa matrice ha dimensione uguale a 3 dato che la rotazione è effettuata in 2 dimensioni.
L’array “args” contiene un singolo parametro ovvero l’angolo in radianti.
"""
@inline function r2D(args)
	angle = args[1]; COS = cos(angle); SIN = sin(angle)
	mat = Matrix{Float64}(LinearAlgebra.I, 3, 3)
	mat[1,1] = COS;    mat[1,2] = -SIN;
	mat[2,1] = SIN;    mat[2,2] = COS;
	return mat
end

"""
	rX(mat::Matrix,COS,SIN)::Matrix
Ritorna la matrice “mat” passata come parametro, "ruotata" rispetto all'asse delle ascisse secondo i parametri COS e SIN.
"""
@inline function rX(mat,COS,SIN)
	mat[2,2] = COS;    mat[2,3] = -SIN;
	mat[3,2] = SIN;    mat[3,3] = COS;
	return mat
end

"""
	rY(mat::Matrix,COS,SIN)::Matrix
Ritorna la matrice “mat” passata come parametro, "ruotata" rispetto all'asse delle ordinate secondo i parametri COS e SIN.
"""
@inline function rY(mat,COS,SIN)
	mat[1,1] = COS;    mat[1,3] = SIN;
	mat[3,1] = -SIN;    mat[3,3] = COS;
	return mat
end

"""
	rZ(mat::Matrix,COS,SIN)::Matrix
Ritorna la matrice “mat” passata come parametro, "ruotata" rispetto all'asse delle quote secondo i parametri COS e SIN.
"""
@inline function rZ(mat,COS,SIN)
	mat[1,1] = COS;    mat[1,2] = -SIN;
	mat[2,1] = SIN;    mat[2,2] = COS;
	return mat
end

"""
	rAxis(mat::Matrix,axis,COS,SIN)::Matrix
Ritorna la matrice “mat” passata come parametro, "ruotata" rispetto all'asse axis, passato come parametro, secondo i parametri COS e SIN.
"""
@inline @fastmath function rAxis(mat,axis,COS,SIN)
	i = SMatrix{3,3,Float64}(1I)
    u = axis
	Ux = [0 -u[3] u[2] ; u[3] 0 -u[1] ;  -u[2] u[1] 1]
	UU =[u[1]*u[1]    u[1]*u[2]   u[1]*u[3];
         u[2]*u[1]    u[2]*u[2]   u[2]*u[3];
         u[3]*u[1]    u[3]*u[2]   u[3]*u[3]]
	mat[1:3,1:3]=COS*i+SIN*Ux+(1.0-COS)*UU
	return mat
end

"""
	r3D(args::Array{Float64,1}...)::Matrix
Genera e ritorna la matrice “mat” di trasformazione affine(di rotazione in 3D) in coordinate omogenee.
Questa matrice ha dimensione uguale a 4 dato che la rotazione è effettuata in 3 dimensioni.
L'array "args" contiene un vettore con tre elementi, la cui “norma” è l 'angolo di rotazione in 3D e
il cui “valore normalizzato” fornisce la direzione dell’asse di rotazione in 3D.
"""
@inline function r3D(args)
	mat = Matrix{Float64}(LinearAlgebra.I, 4, 4)
	angle = norm(args);
	if angle != 0.0
		 axis = args #normalize(args)
		 COS = cos(angle); SIN= sin(angle)
		 if axis[2]==axis[3]==0.0    # rotation about x
			 mat = rX(mat,COS,SIN)
		 elseif axis[1]==axis[3]==0.0   # rotation about y
			 mat = rY(mat,COS,SIN)
		 elseif axis[1]==axis[2]==0.0    # rotation about z
			 mat = rZ(mat,COS,SIN)
		 else
			 mat = rAxis(mat,axis,COS,SIN)
		 end
	 end
	 return mat
end

"""
	r(args...)::Matrix
Se l’array “args” contiene un singolo parametro ovvero l’angolo in radianti chiama r2D per la rotazione in 2 dimensioni,
se invece contiene un vettore con tre elementi chiama r3D per quella in tre dimensioni.
Restituisce la matrice mat di rotazione.
```julia
julia> Lar.r(pi/6)				# 2D rotation of ``π/6`` angle
# return
3×3 Array{Float64,2}:
 0.866025  -0.5       0.0
 0.5        0.866025  0.0
 0.0        0.0       1.0
julia> Lar.r(0,0,pi/4)
# return
4×4 Array{Float64,2}:		# 3D rotation about the ``z`` axis, with ``π/6`` angle
 0.707107  -0.707107  0.0  0.0
 0.707107   0.707107  0.0  0.0
 0.0        0.0       1.0  0.0
 0.0        0.0       0.0  1.0
julia> Lar.r(1,1,1)		# 3D rotation about the ``x=y=z`` axis, with angle ``1.7320508`` angle
# return
4×4 Array{Float64,2}:
  0.226296  -0.183008   0.956712  0.0
  0.956712   0.226296  -0.183008  0.0
 -0.183008   0.956712   1.21332   0.0
  0.0        0.0        0.0       1.0
```
"""
@inline function r(args...)
   n = length(args)

   if n == 1 # rotation in 2D
	   mat = r2D(args)
   end

    if n == 3 # rotation in 3D
       mat = r3D(args)
	end
	return mat
end


"""
	sortCells(CW::Cells)::Cells
Mette “Cells” in forma canonica, ovvero vengono ordinati gli indici di vertici in ogni singolo elemento dell’array “Cells”.
"""
function sortCells(CW)
	CWs = collect(map(sort!,CW))
	return CWs
end

"""
	removeDups(CW::Cells)::Cells
Rimuove le celle duplicate dall’oggetto “Cells”.
"""
function removeDups(CW)
	CW = collect(Set(CW))
	sortCells(CW)
end


"""
	Struct
Funzione che applicata ad un array di oggetti crea un “contenitore” di oggetti geometrici con i seguenti attributi: <body, box, name, dim, category>.
Ogni valore è definito in coordinate locali e può essere trasformato da tensori di trasformazione affini. Il valore restituito è di tipo “Struct” ed
il suo sistema di coordinate è quello associato al primo oggetto degli argomenti della funzione. Inoltre, il valore geometrico risultante è spesso
associato a un nome di variabile. La generazione dei contenitori può continuare gerarchicamente applicando opportunamente “Struct”.
La definizione della struttura come “mutable” permette grazie all’utilizzo di apposite funzioni,
la modifica degli attributi anche dopo la creazione/costruzione della struttura.
# Example
```julia
julia> L = LinearAlgebraicRepresentation;
julia> assembly = L.Struct([L.sphere()(), L.t(3,0,-1), L.cylinder()()])
# return
Lar.Struct(Any[([0.0 -0.173648 … -0.336824 -0.17101; 0.0 0.0 … 0.0593912 0.0301537;
-1.0 -0.984808 … 0.939693 0.984808], Array{Int64,1}[[2, 3, 1], [4, 2, 3], [4, 3, 5], [4,
5, 6], [7, 5, 6], [7, 8, 6], [7, 9, 8], … , [1.0 0.0 0.0 3.0; 0.0 1.0 0.0 0.0; 0.0 0.0 1.0
-1.0; 0.0 0.0 0.0 1.0], ([0.5 0.5 … 0.492404 0.492404; 0.0 0.0 … -0.0868241 -0.0868241;
0.0 2.0 … 0.0 2.0], Array{Int64,1}[[4, 2, 3, 1], [4, 3, 5, 6], [7, 5, 8, 6], [7, 9, 10,
8], [9, 10, 11, 12], [13, 14, 11, 12], … , [68, 66, 67, 65], [68, 69, 67, 70], [71, 69,
72, 70], [71, 2, 72, 1]])], Array{Float64,2}[[-1.0; -1.0; -1.0], [3.5; 1.0; 1.0]],
"14417445522513259426", 3, "feature")
julia> assembly.name = "simple example"
# return
"simple example"
julia> assembly
# return
Lar.Struct(Any[([0.0 -0.173648 … -0.336824 -0.17101; 0.0 0.0 … 0.0593912 0.0301537;
-1.0 -0.984808 … 0.939693 0.984808], Array{Int64,1}[[2, 3, 1], [4, 2, 3], [4, 3, 5], [4,
5, 6], [7, 5, 6], [7, 8, 6], … , [71, 2, 72, 1]])], Array{Float64,2}[[-1.0; -1.0; -1.0],
[3.5; 1.0; 1.0]], "simple example", 3, "feature")
julia> using Plasm
julia> Plasm.view(assembly)
```
"""
mutable struct Struct
	body::Array
	box
	name::AbstractString
	dim::Int
	category::AbstractString

	function Struct()
		self = new([],Any,"new",0,"feature")
		self.name = string(objectid(self))
		return self
	end

	function Struct(data)
		self = Struct()
		self.body = data
		self.box = box(self)
		self.dim = length(self.box[1])
		return self
	end

	function Struct(data,name)
		self = Struct()
		self.body=[item for item in data]
		self.box = box(self)
		self.dim = length(self.box[1])
		self.name = string(name)
		return self
	end

	function Struct(data,name,category)
		self = Struct()
		self.body = [item for item in data]
		self.box = box(self)
		self.dim = length(self.box[1])
		self.name = string(name)
		self.category = string(category)
		return self
	end
end

"""
	name(self::Struct)::AbstractString
Restituisce il nome della struttura di tipo “AbstractString”.
"""
	function name(self)
		return self.name
	end

"""
	category(self::Struct)::AbstractString
Restituisce la categoria della struttura di tipo “AbstractString”.
"""
	function category(self)
		return self.category
	end

"""
	len(self::Struct)::Int
Restituisce la lunghezza del grafo(attributo “body” di tipo “Array”) della struttura.
"""
	function len(self)
		return length(self.body)
	end

"""
	getItem(self::Struct, i::Int)::Array
Restituisce l’oggetto con indice “i” nel corpo(grafo) della struttura.
"""
	function getItem(self,i)
		return self.body[i]
	end

"""
	setItem(self::Struct, i::Int)
Imposta il valore dell’oggetto con indice “i” nel corpo della struttura a “value”.
"""
	function setItem(self,i,value)
		self.body[i]=value
	end

"""
	pprint(self::Struct)::String
Restituisce il nome della struttura.
"""
	function pprint(self)
		return "<Struct name: $(self.name)"
	end

"""
	set_name(self::Struct, name::String)
Imposta il nome della struttura a “name”.
"""
	function set_name(self,name)
		self.name = string(name)
	end

"""
	clone(self::Struct, i::Int)::Struct
Restituisce l’oggetto “newObj” che contiene una copia della struttura.
"""
	function clone(self,i)
		newObj = deepcopy(self)
		if i!=0
			newObj.name="$(self.name)_$(string(i))"
		end
		return newObj
	end

"""
	set_category(self::Struct, category::AbstractString)
Imposta la categoria della struttura a “category”.
"""
	function set_category(self,category)
		self.category = string(category)
	end


"""
	flatten(listOfModels::Array)::Array{...},Array
"Appiattisce” la struttura fondamentalmente in un’unica struttura dati di tipo LAR.
Trasforma la gerarchia in un solo modello LAR.
"""
function flatten(listOfModels)
	W = Array{Float64,1}[]
	m = length(listOfModels[1])
	larmodel = [Array{Float64,1}[] for k=1:m]
	vertDict = Dict()
	index,defaultValue = 0,0
	for model in listOfModels
		V = model[1]
		for k=2:m
			for incell in model[k]
				outcell=[]
				@simd for v in incell
					key = map(Lar.approxVal(7), V[:,v])
					if get!(vertDict,key,defaultValue)==defaultValue
						index += 1
						vertDict[key]=index
						push!(outcell,index)
						push!(W,key)
					else
						push!(outcell,vertDict[key])
					end
				end
				append!(larmodel[k],[outcell])
			end
		end
	end
	return larmodel,W
end

"""
	struct2lar(structure::Struct)::Union{LAR,LARmodel}
Restituisce una tupla(vertici,celle,spigoli) che consiste nella rappresentazione algebrica lineare della struttura in ingresso.
"""
function struct2lar(structure)
	larmodel,W = flatten(evalStruct(structure))
	append!(larmodel[1], W)
	V = hcat(larmodel[1]...)
	chains = [convert(Lar.Cells, chain) for chain in larmodel[2:end]]
	return (V, chains...)
end


"""
	embedTraversalMatrix(objBody::Matrix,n::Int)::Matrix
Funzione chiamata se il corpo della struttura che si sta modellando è una matrice. Trasforma la matrice aumentandone la dimensione del valore n.
"""
@inline function embedTraversalMatrix(objBody,n)
	mat = objBody
	d,d = size(mat)
	newMat = Matrix{Float64}(LinearAlgebra.I, d+n, d+n)
	@inbounds for h in range(1, length=d)
		@inbounds for k in range(1, length=d)
			newMat[h,k]=mat[h,k]
		end
	end
	return newMat
end

"""
	embedTraversalTupleOrArray(objBody::Union{Tuple,Array},V)
Funzione chiamata se il corpo della struttura che si sta modellando è una tupla o un array. Genera e restituisce il parametro V.
"""
@inline function embedTraversalTupleOrArray(n,V)
	dimadd = n
	ncols = size(V,2)
	nmat = zeros(dimadd,ncols)
	V = [V;nmat]
	return V
end

"""
	embedTraversalStruct(objBody::Struct)::Struct
Funzione chiamata se il corpo della struttura che si sta modellando è una struttura.
Genera(a partire dalla struttura in ingresso objBody) e restituisce, la struttura newObj.
"""
@inline function embedTraversalStruct(objBody)
	newObj = Struct()
	newObj.box = [ [objBody.box[1];zeros(dimadd)],
				   [objBody.box[2];zeros(dimadd)] ]
	newObj.category = objBody.category
	return
end

"""
	embedTraversal(cloned::Struct,obj::Struct,n::Int,suffix::String)::Struct
Restituisce l’oggetto cloned di tipo “struct” che consiste in una struttura avente
lo stesso body della struttura “obj” passata come parametro. Sono visitati uno
per uno gli elementi del body di obj e siano essi matrici, tuple, array o a loro
volta strutture, sono copiati all’interno di variabili locali e inserite nella struttura
“cloned”.
"""
@inline function embedTraversal(cloned,obj,n,suffix)
	objBody = obj.body
	# for sync o async?
	@inbounds @sync for i=1:length(objBody)
		if (isa(objBody[i],MMatrix) || isa(objBody[i],Matrix))
			newMat = embedTraversalMatrix(objBody[i],n)
			push!(cloned.body,[newMat])
		elseif (isa(objBody[i],Tuple) || isa(objBody[i],Array))
			if (length(objBody[i])==3)
				V,FV,EV = deepcopy(objBody[i])
				V = embedTraversalTupleOrArray(n,V)
				push!(cloned.body,[(V,FV,EV)])
			elseif (length(objBody[i])==2)
				V,EV = deepcopy(objBody[i])
				V = embedTraversalTupleOrArray(n,V)
				push!(cloned.body,[(V,EV)])
			end
		elseif isa(objBody[i],Struct)
			newObj = embedTraversalStruct(objBody[i])
			push!(cloned.body,[embedTraversal(newObj,objBody[i],obj.dim+n,suffix)])
		end
	end
	return cloned
end


"""
	embedStruct(n::Int)(self::Struct,suffix::String)::Struct
Restituisce una struttura che è la copia della struttura “self” passata come
parametro, dove però la dimensione è aumentata del fattore “n” e al nome è
posto il suffisso. Per copiare il body è chiamata “embedTraversal”.
"""
function embedStruct(n)
	function embedStruct0(self, suffix)
		if n==0
			return self, length(self.box[1])
		end
		cloned = Struct()
		cloned.box = hcat((self.box,[fill([0],n),fill([0],n)]))
		cloned.name = self.name*suffix
		cloned.category = self.category
		cloned.dim = self.dim+n
		cloned = embedTraversal(cloned,self,n,suffix)
		return cloned
	end
	return embedStruct0
end


"""
	evalBox(listOfModels::Array)::Tuple
Genera e restituisce  il volume di contenimento, ovvero il minimo parallelepipedo parallelo agli assi che li contiene.
"""
@inline function evalBox(listOfModels)
	theMin,theMax = box(listOfModels[1])
	for theModel in listOfModels[2:end]
		modelMin,modelMax= box(theModel)
		for (k,val) in enumerate(modelMin)
			if val < theMin[k]
				theMin[k]=val
			end
		end
		for (k,val) in enumerate(modelMax)
			if val > theMax[k]
				theMax[k]=val
			end
		end
	end
	return theMin,theMax
end

"""
	box(model)::Array
I box sono associati ai nodi, ovvero alle strutture. Sia il modello in ingresso una struttura, una tupla o un’array,
restituisce [theMin,theMax] che rappresenta il volume di contenimento. Estrae quindi il solo volume di vista,
caratterizzato dai parametri del box stesso(angolo di apertura, direzione asse, …).
"""
@inline function box(model)
	if (isa(model,MMatrix) || isa(model,Matrix))
		return nothing
	elseif isa(model,Struct)
		listOfModels = evalStruct(model)
		if listOfModels == []
			return model.box
		else
			theMin,theMax = evalBox(listOfModels)
		end

		return [theMin,theMax]

	elseif (isa(model,Tuple) || isa(model,Array)) && (length(model)>=2)
		V = model[1]
		theMin = minimum(V, dims=2)
		theMax = maximum(V, dims=2)
	end

	return [theMin,theMax]
end


"""
	apply(affineMatrix::Array{Float64,2}, larmodel::Union{LAR,LARmodel})
Modifica l’oggetto “larmodel” passato come parametro e lo restituisce di tipo
tupla. Nello specifico è una coppia (Geometria, Topologia) in cui la prima è
memorizzata come “punti”, mentre la seconda come “array di celle”.
I suoi vertici vengono modificati secondo la matrice di affinità “affineMatrix”
moltiplicata per il parametro “W” calcolato all’interno della funzione.
"""
function apply(affineMatrix, larmodel)
	data = collect(larmodel)
	V = data[1]

	m,n = size(V)
	W = [V; fill(1.0, (1,n))]
	V = (affineMatrix * W)[1:m,1:n]

	data[1] = V
	larmodel = Tuple(data)
	return larmodel
end


"""
	checkStruct(lst)::Int
Calcola e ritorna la dimensione “dim” dell’oggetto “lst”.
"""
function checkStruct(lst)
	obj = lst[1]
	if (isa(obj,MMatrix) || isa(obj,Matrix))
		dim = size(obj,1)-1
	elseif (isa(obj,Tuple) || isa(obj,Array))
		dim = length(@view (obj[1][:,1]))

	elseif isa(obj,Struct)
		dim = length(obj.box[1])
	end
	return dim
end


"""
	traversal(CTM,stack,obj,scene)
Trasformazione della gerarchia in un unico sistema di coordinate, ovvero quello della radice(chiamate coordinate mondo).
Viene visitato in profondità il grafo(obj.body). Durante la visita viene conservata una matrice CTM(current transformation matrix)
che viene inizializzata quando si parte dalla radice. Quando nella visita si incontra una matrice si aggiorna la CTM moltiplicandola
per essa(vengono moltiplicati i vertici). Man a mano che il grafo viene visitato si può pensare che la matrice resti associata all’ultimo
arco e quando si entra in un nodo per visitarne il sottoalbero di cui è radice, bisogna salvare lo stato corrente di questa matrice facendo
un “push” della CTM su uno stack. Quando invece si esce dal sottoalbero, si fa un “pop” dello stack.
"""
function traversal(CTM, stack, obj, scene)
	#for sync o async?
	@inbounds @sync for i in 1:length(obj.body)
		if (isa(obj.body[i],MMatrix) || isa(obj.body[i],Matrix))
			CTM = CTM*obj.body[i]
		elseif (isa(obj.body[i],Tuple) || isa(obj.body[i],Array)) && (length(obj.body[i])>=2)
			l = apply(CTM, obj.body[i])
			push!(scene,l)
		elseif isa(obj.body[i],Struct)
			push!(stack,CTM)
			traversal(CTM,stack,obj.body[i],scene)
			CTM = pop!(stack)
		end
	end
	return scene
end


"""
	evalStruct(self::Struct)
Esegue una valutazione della struttura "self" in ingresso. Inizializza una matrice
CTM di dimensione "dimensione struttura + 1" x "dimensione struttura + 1" e ritorna
la struttura traformata in coordinate mondo, chiamando la funzione "traversal".
"""
function evalStruct(self)
	dim = checkStruct(self.body)
	CTM = Matrix{Float64}(LinearAlgebra.I, dim+1, dim+1)
	return traversal(CTM, [], self, [])
end
