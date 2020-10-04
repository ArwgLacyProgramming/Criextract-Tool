if (heapSize < 200000) then
        heapSize = 2000000 	
fname = getOpenFileName \
caption:"Open .* from Mesh folder" \
types:"CryEngine Static Models (*.skinm;*.cgf;)|*.skinm;*.cgf; " \ 
historyCategory:"CryObjectPresets"
f = fopen fname "rb"

clearlistener()
fn readHalfFloat fstream = (
    hf=readshort fstream #unsigned
    sign = bit.get hf 16
    exponent = (bit.shift (bit.and hf (bit.hexasint "7C00")) -10) as integer - 16
    fraction = bit.and hf (bit.hexasint "03FF")
    if sign==true then sign = 1 else sign = 0
    exponentF = exponent + 127
    outputAsFloat = bit.or (bit.or (bit.shift fraction 13) \
    (bit.shift exponentF 23)) (bit.shift sign 31)
    return bit.intasfloat outputasfloat*2
    )
fn readFixedString bstream fixedLen = (
local str = ""
for i = 1 to fixedLen do (
str += bit.intAsChar (ReadByte bstream #unsigned))
str
)
struct weight_data
(
	boneids,weights
)
struct bone_map_data
(
	MapId
)
clearlistener()

vert_info_array = #()
bone_info_array = #()
parent_info_array = #()
unk_info_array = #()
weight_info_array = #()
BNArr = #()
BoneMapArray	= #()
map_info_array = #()
ChildCountArr = #()
model_name_array = #()
model_name_array2 = #()
parentless_array = #()

clearlistener()

fseek f 0x8 #seek_set
DataCount = readlong f
DataSize = readlong f

for x = 1 to DataCount do (
getPos = ftell f + DataSize
Type = readbyte f
Type2 = readbyte f
SecId = readshort f
if Type==0 then
(
Unk= readlong f
BoneOffset= readlong f
Id=readlong f
Unk2=readlong f
)		
if Type==1 then
(
Id=readlong f
SecSize= readlong f
ParentOffset= readlong f
append parent_info_array ParentOffset		
)	
if Type==2 then
(
Id=readlong f	
SecSize= readlong f
UnkOffset= readlong f
)		
if Type==5 then
(
Id=readlong f	
SecSize= readlong f
WeightOffset= readlong f
)
if Type==11 then
(
Id=readlong f	
SecSize= readlong f
ModelNameOffset2= readlong f
)	
if Type==21 then
(
Unk= readlong f
Offset= readlong f
Id=readlong f
Unk2=readlong f
)	
if Type==22 then
(
Id=readlong f	
SecSize= readlong f
Offset= readlong f
)	
if Type==23 then
(
Id=readlong f	
SecSize= readlong f
MapOffset= readlong f
)	
fseek f getPos #seek_set	
if Type==2 then
(	
append unk_info_array UnkOffset	
)
if Type==5 then
(	
append weight_info_array WeightOffset	
)	
if Type==11 then
(	
append model_name_array2 ModelNameOffset2
)	
if Type==22 then
(	
append vert_info_array Offset
)
if Type==23 then
(	
append map_info_array MapOffset
)	
)

MapOff=map_info_array[1]
fseek f MapOff #seek_set

FaceCountArray = #()
FacePosArray = #()
VertexCountArray = #()
VertexEnd = #()
ModelOrderArray = #()

Unk=readlong f
DataCount = readlong f
fseek f 8 #seek_cur 	

Print ("Model Info Chunk Start @ 0x"+((bit.intAsHex(ftell f))as string))

for x = 1 to DataCount do 
(
FacePos=readlong f
FaceCount = readlong f
VPos = readlong f	
VertexCount = readlong f	
ModelNumber =  readlong f	
fseek f 0x10 #seek_cur 
Print ("Vertex Count: "+((VertexCount)as string))	
Print ("Face Count: "+((FaceCount)as string))
append ModelOrderArray ModelNumber	
append VertexEnd VPos
append FacePosArray FacePos	
append FaceCountArray FaceCount	
append VertexCountArray VertexCount		
)		

print VertexEnd
print FacePosArray
	
ChunkOneType =#()
SecSize	=#()

Print ("Vert Info Start @ 0x"+((bit.intAsHex(ftell f))as string))	

for i = 1 to vert_info_array.count do (	
COff=vert_info_array[i]
fseek f COff #seek_set
		
Unk=readlong f
ChunkType = readlong f
Count = readlong f	
Size = readlong f
fseek f 0x8 #seek_cur	
append ChunkOneType ChunkType
append SecSize Count
)		
	
Print ("ChunkOneType:"+(ChunkOneType as string))

if DataCount>1 then (
Stride=(VertexEnd[2]-VertexCountArray[1])	
)	
print Stride	

Print ("Model Info2 Start @ 0x"+((bit.intAsHex(ftell f))as string))	

ModelInfo2=model_name_array2[1]

fseek f ModelInfo2 #seek_set	

ModelName2=#()	
for i=1 to 1 do (	
getPos = ftell f + 132			
append ModelName2 (readString f) 
fseek f getPos #seek_set		
)
	
StrideX=readfloat f
StrideY=readfloat f
StrideZ=readfloat f
	
Print ("Model Info2 End @ 0x"+((bit.intAsHex(ftell f))as string))	

for i = 1 to DataCount do (	
	
vertArray = #()
Facearray = #()	
UV_array = #()	
Weight_array =#()
BoneMapId = #()	
	
fseek f (vert_info_array[1]-24) #seek_set

BBMinX=readfloat f
BBMinY=readfloat f
BBMinZ=readfloat f

BBMaxX=readfloat f
BBMaxY=readfloat f
BBMaxZ=readfloat f

fseek f (vert_info_array[1]+12) #seek_set

VertDataSize=readlong f

fseek f (vert_info_array[1]+24) #seek_set
		
if Stride==1 then  VertexCountArray[i]=(VertexCountArray[i]+1)	

if Stride!=1 then  VertexCountArray[i]=(VertexCountArray[i]+0)	

if DataCount==1 then VertexCountArray[i]=SecSize[1]	

print VertexCountArray[i]

if ChunkOneType[1]==0 then (
	
Print ("Vertex Start @ 0x"+((bit.intAsHex(ftell f))as string))		
	
VertOff=ftell f
if VertDataSize==8 then (	
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set

for x = 1 to (VertexCountArray[i]) do (
vx = readHalfFloat f
vy = readHalfFloat f
vz = readHalfFloat f
Null = readHalfFloat f		
append vertArray ([-vx,-vy,vz]*100)
)
Print ("Vertex End @ 0x"+((bit.intAsHex(ftell f))as string))	
)	

if VertDataSize==12 then (	
fseek f (VertOff+(VertexEnd[i]*12)) #seek_set

for x = 1 to (VertexCountArray[i]) do (
vx = readFloat f
vy = readFloat f
vz = readFloat f	
append vertArray ([-vx,-vy,vz]*100)
)
Print ("Vertex End @ 0x"+((bit.intAsHex(ftell f))as string))	
)	
)

if ChunkOneType[1]==15 then (
	
Print ("Vertex Start @ 0x"+((bit.intAsHex(ftell f))as string))		
	
VertOff=ftell f
if VertDataSize==8 then (	
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set

for x = 1 to (VertexCountArray[i]) do (
vx = readHalfFloat f
vy = readHalfFloat f
vz = readHalfFloat f
Null = readHalfFloat f		
append vertArray ([-vx,-vy,vz]*100)
)
Print ("Vertex End @ 0x"+((bit.intAsHex(ftell f))as string))	
)	

if VertDataSize==12 then (	
fseek f (VertOff+(VertexEnd[i]*12)) #seek_set

for x = 1 to (VertexCountArray[i]) do (
vx = readFloat f
vy = readFloat f
vz = readFloat f	
append vertArray ([-vx,-vy,vz]*100)
)
Print ("Vertex End @ 0x"+((bit.intAsHex(ftell f))as string))	
)

if VertDataSize==16 then (	
fseek f (VertOff+(VertexEnd[i]*16)) #seek_set

for x = 1 to (VertexCountArray[i]) do (
vx = readHalfFloat f
vy = readHalfFloat f
vz = readHalfFloat f
Null = readHalfFloat f		
FFFF=readlong f	
tu = readHalfFloat f
tv = readHalfFloat f*-1	
append vertArray ([-vx,-vy,vz]*100)
append UV_array [tu,tv,0]	 		
)
Print ("Vertex End @ 0x"+((bit.intAsHex(ftell f))as string))		
)
)

if ChunkOneType[1]==1 do (	
for x = 1 to VertexCountArray[i] do 
(	
nx = readFloat f
ny = readFloat f
nz = readFloat f
)	
vert_info_array[1]+=(VertexCountArray[i]*12)
)

if ChunkOneType[1]==2 do (
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set		
	
for x = 1 to VertexCountArray[i] do (	
tu = readFloat f
tv = readFloat f*-1
append UV_array [tu,tv,0]	 	
)
)

if ChunkOneType[1]==3 do 	(
for x = 1 to VertexCountArray[i] do (
tx = readFloat f
ty = readFloat f
tz = readFloat f
tw = readFloat f	
)	
vert_info_array[1]+=(VertexCountArray[i]*16)
)
	
if ChunkOneType[1]==5 then (	
	
FaceOff=ftell f
fseek f (FaceOff+(FacePosArray[i]*2)) #seek_set

Print ("Face Start @ 0x"+((bit.intAsHex(ftell f))as string))	

for x = 1 to (FaceCountArray[i]/3) do 
(	
f1 = (Readshort f #unsigned + 1) - VertexEnd[i]
f2 = (Readshort f #unsigned + 1) - VertexEnd[i]
f3 = (Readshort f #unsigned + 1) - VertexEnd[i]	
append Facearray [f1,f2,f3] 	
)
Print ("Face End @ 0x"+((bit.intAsHex(ftell f))as string))	
)

if ChunkOneType[1]==6 do (	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 16
fseek f getPos #seek_set
)	
vert_info_array[1]+=(VertexCountArray[i]*16)
)

if ChunkOneType[1]==8 do (	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 28
fseek f getPos #seek_set
)	
vert_info_array[1]+=(VertexCountArray[i]*28)
)

if ChunkOneType[1]==9 do 	(
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set			
	
Print ("Weights Start @ 0x"+((bit.intAsHex(ftell f))as string))	
	
for x = 1 to VertexCountArray[i] do 
(
	
bone1 = readbyte f #unsigned	
bone2 = readbyte f #unsigned	
bone3 = readbyte f #unsigned	
bone4 = readbyte f #unsigned	
		
weight1 = readbyte f #unsigned	
weight2 = readbyte f #unsigned
weight3 = readbyte f #unsigned
weight4 = readbyte f #unsigned

w = (weight_data boneids:#() weights:#())
maxweight = 0
if(weight1 != 0) then
   maxweight = maxweight + weight1
if(weight2 != 0) then
   maxweight = maxweight + weight2
if(weight3 != 0) then
   maxweight = maxweight + weight3
if(weight4 != 0) then
   maxweight = maxweight + weight4


if(maxweight != 0) then (
      if(weight1 != 0) then (
         w1 = weight1 as float
         append w.boneids (bone1 + 1)
         append w.weights (w1/255.0)
      )
      if(weight2 != 0) then (
         w2 = weight2 as float
         append w.boneids (bone2 + 1)
         append w.weights (w2/255.0)
      )
      if(weight3 != 0) then (
         w3 = weight3 as float
         append w.boneids (bone3 + 1)
         append w.weights (w3/255.0)
      )
      if(weight4 != 0) then (
         w4 = weight4 as float
         append w.boneids (bone4 + 1)
        append w.weights (w4/255.0)
      )      
   )
append Weight_array w		
)
)

fseek f vert_info_array[2] #seek_set
	
fseek f 0x4 #seek_cur
CType = (readlong f)
Count = readlong f	
Size = readlong f
fseek f 0x8 #seek_cur	


if ChunkOneType[2]==0 then (
for x = 1 to (VertexCountArray[i]) do (
vx = readFloat f
vy = readFloat f
vz = readFloat f	
append vertArray ([-vx,-vy,vz]*100)
)
vert_info_array[2]+=((VertexCountArray[i])*12)
)

if ChunkOneType[2]==1 do (	
for x = 1 to VertexCountArray[i] do 
(	
nx = readFloat f
ny = readFloat f
nz = readFloat f
)	
vert_info_array[2]+=(VertexCountArray[i]*12)
)

if ChunkOneType[2]==2 do (
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set		
	
for x = 1 to VertexCountArray[i] do (	
tu = readFloat f
tv = readFloat f*-1
append UV_array [tu,tv,0]	 	
)
)

if ChunkOneType[2]==3 do 	(
for x = 1 to VertexCountArray[i] do (
tx = readFloat f
ty = readFloat f
tz = readFloat f
tw = readFloat f	
)	
vert_info_array[2]+=(VertexCountArray[i]*16)
)
	
if ChunkOneType[2]==5 then (	
	
FaceOff=ftell f
fseek f (FaceOff+(FacePosArray[i]*2)) #seek_set

Print ("Face Start @ 0x"+((bit.intAsHex(ftell f))as string))	

for x = 1 to (FaceCountArray[i]/3) do 
(	
f1 = (Readshort f #unsigned + 1) - VertexEnd[i]
f2 = (Readshort f #unsigned + 1) - VertexEnd[i]
f3 = (Readshort f #unsigned + 1) - VertexEnd[i]	
append Facearray [f1,f2,f3] 	
)
Print ("Face End @ 0x"+((bit.intAsHex(ftell f))as string))	
)

if ChunkOneType[2]==6 do (	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 16
fseek f getPos #seek_set
)	
vert_info_array[2]+=(VertexCountArray[i]*16)
)

if ChunkOneType[2]==8 do (	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 28
fseek f getPos #seek_set
)	
vert_info_array[2]+=(VertexCountArray[i]*28)
)

if ChunkOneType[2]==9 do 	(
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set			
	
Print ("Weights Start @ 0x"+((bit.intAsHex(ftell f))as string))	
	
for x = 1 to VertexCountArray[i] do 
(
	
bone1 = readbyte f #unsigned	
bone2 = readbyte f #unsigned	
bone3 = readbyte f #unsigned	
bone4 = readbyte f #unsigned	
		
weight1 = readbyte f #unsigned	
weight2 = readbyte f #unsigned
weight3 = readbyte f #unsigned
weight4 = readbyte f #unsigned

w = (weight_data boneids:#() weights:#())
maxweight = 0
if(weight1 != 0) then
   maxweight = maxweight + weight1
if(weight2 != 0) then
   maxweight = maxweight + weight2
if(weight3 != 0) then
   maxweight = maxweight + weight3
if(weight4 != 0) then
   maxweight = maxweight + weight4


if(maxweight != 0) then (
      if(weight1 != 0) then (
         w1 = weight1 as float
         append w.boneids (bone1 + 1)
         append w.weights (w1/255.0)
      )
      if(weight2 != 0) then (
         w2 = weight2 as float
         append w.boneids (bone2 + 1)
         append w.weights (w2/255.0)
      )
      if(weight3 != 0) then (
         w3 = weight3 as float
         append w.boneids (bone3 + 1)
         append w.weights (w3/255.0)
      )
      if(weight4 != 0) then (
         w4 = weight4 as float
         append w.boneids (bone4 + 1)
        append w.weights (w4/255.0)
      )      
   )
append Weight_array w		
)
)

fseek f vert_info_array[3] #seek_set
	
fseek f 0x4 #seek_cur
CType = (readlong f)
Count = readlong f	
Size = readlong f
fseek f 0x8 #seek_cur	


if ChunkOneType[3]==0 then (
for x = 1 to (VertexCountArray[i]) do (
vx = readFloat f
vy = readFloat f
vz = readFloat f	
append vertArray ([-vx,-vy,vz]*100)
)
vert_info_array[3]+=((VertexCountArray[i])*12)
)

if ChunkOneType[3]==1 do (	
for x = 1 to VertexCountArray[i] do 
(	
nx = readFloat f
ny = readFloat f
nz = readFloat f
)	
vert_info_array[8]+=(VertexCountArray[i]*12)
)

if ChunkOneType[3]==2 do (
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set		
	
for x = 1 to VertexCountArray[i] do (	
tu = readFloat f
tv = readFloat f*-1
append UV_array [tu,tv,0]	 	
)
)

if ChunkOneType[3]==3 do 	(
for x = 1 to VertexCountArray[i] do (
tx = readFloat f
ty = readFloat f
tz = readFloat f
tw = readFloat f	
)	
vert_info_array[8]+=(VertexCountArray[i]*16)
)
	
if ChunkOneType[3]==5 then (	
	
FaceOff=ftell f
fseek f (FaceOff+(FacePosArray[i]*2)) #seek_set

Print ("Face Start @ 0x"+((bit.intAsHex(ftell f))as string))	

for x = 1 to (FaceCountArray[i]/3) do 
(	
f1 = (Readshort f #unsigned + 1) - VertexEnd[i]
f2 = (Readshort f #unsigned + 1) - VertexEnd[i]
f3 = (Readshort f #unsigned + 1) - VertexEnd[i]	
append Facearray [f1,f2,f3] 	
)
Print ("Face End @ 0x"+((bit.intAsHex(ftell f))as string))	
)

if ChunkOneType[3]==6 do (	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 16
fseek f getPos #seek_set
)	
vert_info_array[3]+=(VertexCountArray[i]*16)
)

if ChunkOneType[3]==8 do (	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 28
fseek f getPos #seek_set
)	
vert_info_array[3]+=(VertexCountArray[i]*28)
)

if ChunkOneType[3]==9 do 	(
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set			
	
Print ("Weights Start @ 0x"+((bit.intAsHex(ftell f))as string))	
	
for x = 1 to VertexCountArray[i] do 
(
	
bone1 = readbyte f #unsigned	
bone2 = readbyte f #unsigned	
bone3 = readbyte f #unsigned	
bone4 = readbyte f #unsigned	
		
weight1 = readbyte f #unsigned	
weight2 = readbyte f #unsigned
weight3 = readbyte f #unsigned
weight4 = readbyte f #unsigned

w = (weight_data boneids:#() weights:#())
maxweight = 0
if(weight1 != 0) then
   maxweight = maxweight + weight1
if(weight2 != 0) then
   maxweight = maxweight + weight2
if(weight3 != 0) then
   maxweight = maxweight + weight3
if(weight4 != 0) then
   maxweight = maxweight + weight4


if(maxweight != 0) then (
      if(weight1 != 0) then (
         w1 = weight1 as float
         append w.boneids (bone1 + 1)
         append w.weights (w1/255.0)
      )
      if(weight2 != 0) then (
         w2 = weight2 as float
         append w.boneids (bone2 + 1)
         append w.weights (w2/255.0)
      )
      if(weight3 != 0) then (
         w3 = weight3 as float
         append w.boneids (bone3 + 1)
         append w.weights (w3/255.0)
      )
      if(weight4 != 0) then (
         w4 = weight4 as float
         append w.boneids (bone4 + 1)
        append w.weights (w4/255.0)
      )      
   )
append Weight_array w		
)
)

fseek f vert_info_array[4] #seek_set
	
fseek f 0x4 #seek_cur
CType = (readlong f)
Count = readlong f	
Size = readlong f
fseek f 0x8 #seek_cur	


if ChunkOneType[4]==0 then (
for x = 1 to (VertexCountArray[i]) do (
vx = readFloat f
vy = readFloat f
vz = readFloat f	
append vertArray ([-vx,-vy,vz]*100)
)
vert_info_array[4]+=((VertexCountArray[i])*12)
)

if ChunkOneType[4]==1 do (	
for x = 1 to VertexCountArray[i] do 
(	
nx = readFloat f
ny = readFloat f
nz = readFloat f
)	
vert_info_array[4]+=(VertexCountArray[i]*12)
)

if ChunkOneType[4]==2 do (
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set		
	
for x = 1 to VertexCountArray[i] do (	
tu = readFloat f
tv = readFloat f*-1
append UV_array [tu,tv,0]	 	
)
)

if ChunkOneType[4]==3 do 	(
for x = 1 to VertexCountArray[i] do (
tx = readFloat f
ty = readFloat f
tz = readFloat f
tw = readFloat f	
)	
vert_info_array[4]+=(VertexCountArray[i]*16)
)
	
if ChunkOneType[4]==5 then (	
	
FaceOff=ftell f
fseek f (FaceOff+(FacePosArray[i]*2)) #seek_set

Print ("Face Start @ 0x"+((bit.intAsHex(ftell f))as string))	

for x = 1 to (FaceCountArray[i]/3) do 
(	
f1 = (Readshort f #unsigned + 1) - VertexEnd[i]
f2 = (Readshort f #unsigned + 1) - VertexEnd[i]
f3 = (Readshort f #unsigned + 1) - VertexEnd[i]	
append Facearray [f1,f2,f3] 	
)
Print ("Face End @ 0x"+((bit.intAsHex(ftell f))as string))	
)

if ChunkOneType[4]==6 do (	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 16
fseek f getPos #seek_set
)	
vert_info_array[4]+=(VertexCountArray[i]*16)
)

if ChunkOneType[4]==8 do (	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 28
fseek f getPos #seek_set
)	
vert_info_array[4]+=(VertexCountArray[i]*28)
)

if ChunkOneType[4]==9 do 	(
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set			
	
Print ("Weights Start @ 0x"+((bit.intAsHex(ftell f))as string))	
	
for x = 1 to VertexCountArray[i] do 
(
	
bone1 = readbyte f #unsigned	
bone2 = readbyte f #unsigned	
bone3 = readbyte f #unsigned	
bone4 = readbyte f #unsigned	
		
weight1 = readbyte f #unsigned	
weight2 = readbyte f #unsigned
weight3 = readbyte f #unsigned
weight4 = readbyte f #unsigned

w = (weight_data boneids:#() weights:#())
maxweight = 0
if(weight1 != 0) then
   maxweight = maxweight + weight1
if(weight2 != 0) then
   maxweight = maxweight + weight2
if(weight3 != 0) then
   maxweight = maxweight + weight3
if(weight4 != 0) then
   maxweight = maxweight + weight4


if(maxweight != 0) then (
      if(weight1 != 0) then (
         w1 = weight1 as float
         append w.boneids (bone1 + 1)
         append w.weights (w1/255.0)
      )
      if(weight2 != 0) then (
         w2 = weight2 as float
         append w.boneids (bone2 + 1)
         append w.weights (w2/255.0)
      )
      if(weight3 != 0) then (
         w3 = weight3 as float
         append w.boneids (bone3 + 1)
         append w.weights (w3/255.0)
      )
      if(weight4 != 0) then (
         w4 = weight4 as float
         append w.boneids (bone4 + 1)
        append w.weights (w4/255.0)
      )      
   )
append Weight_array w		
)
)

-----------------------------------------------------

if vert_info_array[5]!=undefined do (

fseek f vert_info_array[5] #seek_set
	
fseek f 0x4 #seek_cur
CType = (readlong f)
Count = readlong f	
Size = readlong f
fseek f 0x8 #seek_cur	


if ChunkOneType[5]==0 then (
for x = 1 to (VertexCountArray[i]) do (
vx = readFloat f
vy = readFloat f
vz = readFloat f	
append vertArray ([-vx,-vy,vz]*100)
)
vert_info_array[5]+=((VertexCountArray[i])*12)
)

if ChunkOneType[5]==1 do (	
for x = 1 to VertexCountArray[i] do 
(	
nx = readFloat f
ny = readFloat f
nz = readFloat f
)	
vert_info_array[5]+=(VertexCountArray[i]*12)
)

if ChunkOneType[5]==2 do (

VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set		
	
for x = 1 to VertexCountArray[i] do (	
tu = readFloat f
tv = readFloat f*-1
append UV_array [tu,tv,0]	 	
)
)

if ChunkOneType[5]==3 do 	(
for x = 1 to VertexCountArray[i] do (
tx = readFloat f
ty = readFloat f
tz = readFloat f
tw = readFloat f	
)	
vert_info_array[5]+=(VertexCountArray[i]*16)
)
	
if ChunkOneType[5]==5 then (	
	
FaceOff=ftell f
fseek f (FaceOff+(FacePosArray[i]*2)) #seek_set

Print ("Face Start @ 0x"+((bit.intAsHex(ftell f))as string))	

for x = 1 to (FaceCountArray[i]/3) do 
(	
f1 = (Readshort f #unsigned + 1) - VertexEnd[i]
f2 = (Readshort f #unsigned + 1) - VertexEnd[i]
f3 = (Readshort f #unsigned + 1) - VertexEnd[i]	
append Facearray [f1,f2,f3] 	
)
Print ("Face End @ 0x"+((bit.intAsHex(ftell f))as string))	
)

if ChunkOneType[5]==6 do (	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 16
fseek f getPos #seek_set
)	
vert_info_array[5]+=(VertexCountArray[i]*16)
)

if ChunkOneType[5]==8 do (	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 28
fseek f getPos #seek_set
)	
vert_info_array[5]+=(VertexCountArray[i]*28)
)

if ChunkOneType[5]==9 do 	(
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set			
	
Print ("Weights Start @ 0x"+((bit.intAsHex(ftell f))as string))	
		
for x = 1 to VertexCountArray[i] do 
(
	
bone1 = readbyte f #unsigned	
bone2 = readbyte f #unsigned	
bone3 = readbyte f #unsigned	
bone4 = readbyte f #unsigned	
		
weight1 = readbyte f #unsigned	
weight2 = readbyte f #unsigned
weight3 = readbyte f #unsigned
weight4 = readbyte f #unsigned

w = (weight_data boneids:#() weights:#())
maxweight = 0
if(weight1 != 0) then
   maxweight = maxweight + weight1
if(weight2 != 0) then
   maxweight = maxweight + weight2
if(weight3 != 0) then
   maxweight = maxweight + weight3
if(weight4 != 0) then
   maxweight = maxweight + weight4


if(maxweight != 0) then (
      if(weight1 != 0) then (
         w1 = weight1 as float
         append w.boneids (bone1 + 1)
         append w.weights (w1/255.0)
      )
      if(weight2 != 0) then (
         w2 = weight2 as float
         append w.boneids (bone2 + 1)
         append w.weights (w2/255.0)
      )
      if(weight3 != 0) then (
         w3 = weight3 as float
         append w.boneids (bone3 + 1)
         append w.weights (w3/255.0)
      )
      if(weight4 != 0) then (
         w4 = weight4 as float
         append w.boneids (bone4 + 1)
        append w.weights (w4/255.0)
      )      
   )
append Weight_array w		
)
)
)

if vert_info_array[6]!=undefined do (
	
fseek f vert_info_array[6] #seek_set
	
fseek f 0x4 #seek_cur
CType = (readlong f)
Count = readlong f	
Size = readlong f
fseek f 0x8 #seek_cur	

if ChunkOneType[6]==1 do (	
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*12)) #seek_set		
	
for x = 1 to VertexCountArray[i] do 
(	
nx = readFloat f
ny = readFloat f
nz = readFloat f
)	
)

if ChunkOneType[6]==2 do (

VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set		
	
for x = 1 to VertexCountArray[i] do (	
tu = readFloat f
tv = readFloat f*-1
append UV_array [tu,tv,0]	 	
)
)

if ChunkOneType[6]==3 do 	(
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*16)) #seek_set		
	
for x = 1 to VertexCountArray[i] do (
tx = readFloat f
ty = readFloat f
tz = readFloat f
tw = readFloat f	
)	
)
	
if ChunkOneType[6]==5 then (	
	
FaceOff=ftell f
fseek f (FaceOff+(FacePosArray[i]*2)) #seek_set

Print ("Face Start @ 0x"+((bit.intAsHex(ftell f))as string))	

for x = 1 to (FaceCountArray[i]/3) do 
(	
f1 = (Readshort f #unsigned + 1) - VertexEnd[i]
f2 = (Readshort f #unsigned + 1) - VertexEnd[i]
f3 = (Readshort f #unsigned + 1) - VertexEnd[i]	
append Facearray [f1,f2,f3] 	
)
Print ("Face End @ 0x"+((bit.intAsHex(ftell f))as string))	
)

if ChunkOneType[6]==6 do (	
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*16)) #seek_set		
	
for x = 1 to VertexCountArray[i] do 
(
getPos = ftell f + 16
fseek f getPos #seek_set
)	
)

if ChunkOneType[6]==8 do (	
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*28)) #seek_set		
	
for x = 1 to VertexCountArray[i] do (
getPos = ftell f + 28
fseek f getPos #seek_set
)	
)

if ChunkOneType[6]==9 do 	(
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set			
	
Print ("Weights Start @ 0x"+((bit.intAsHex(ftell f))as string))	
	
for x = 1 to VertexCountArray[i] do 
(
	
bone1 = readbyte f #unsigned	
bone2 = readbyte f #unsigned	
bone3 = readbyte f #unsigned	
bone4 = readbyte f #unsigned	
		
weight1 = readbyte f #unsigned	
weight2 = readbyte f #unsigned
weight3 = readbyte f #unsigned
weight4 = readbyte f #unsigned

w = (weight_data boneids:#() weights:#())
maxweight = 0
if(weight1 != 0) then
   maxweight = maxweight + weight1
if(weight2 != 0) then
   maxweight = maxweight + weight2
if(weight3 != 0) then
   maxweight = maxweight + weight3
if(weight4 != 0) then
   maxweight = maxweight + weight4


if(maxweight != 0) then (
      if(weight1 != 0) then (
         w1 = weight1 as float
         append w.boneids (bone1 + 1)
         append w.weights (w1/255.0)
      )
      if(weight2 != 0) then (
         w2 = weight2 as float
         append w.boneids (bone2 + 1)
         append w.weights (w2/255.0)
      )
      if(weight3 != 0) then (
         w3 = weight3 as float
         append w.boneids (bone3 + 1)
         append w.weights (w3/255.0)
      )
      if(weight4 != 0) then (
         w4 = weight4 as float
         append w.boneids (bone4 + 1)
        append w.weights (w4/255.0)
      )      
   )
append Weight_array w		
)
)
)

if vert_info_array[7]!=undefined do (
	
fseek f vert_info_array[7] #seek_set
	
fseek f 0x4 #seek_cur
CType = (readlong f)
Count = readlong f	
Size = readlong f
fseek f 0x8 #seek_cur	

if ChunkOneType[7]==8 do (	
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*28)) #seek_set		
	
for x = 1 to VertexCountArray[i] do (
getPos = ftell f + 28
fseek f getPos #seek_set
)	
)

if ChunkOneType[7]==9 do 	(
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set		
	
Print ("Weights Start @ 0x"+((bit.intAsHex(ftell f))as string))	
	
for x = 1 to VertexCountArray[i] do 
(
	
bone1 = readbyte f #unsigned	
bone2 = readbyte f #unsigned	
bone3 = readbyte f #unsigned	
bone4 = readbyte f #unsigned	
		
weight1 = readbyte f #unsigned	
weight2 = readbyte f #unsigned
weight3 = readbyte f #unsigned
weight4 = readbyte f #unsigned

w = (weight_data boneids:#() weights:#())
maxweight = 0
if(weight1 != 0) then
   maxweight = maxweight + weight1
if(weight2 != 0) then
   maxweight = maxweight + weight2
if(weight3 != 0) then
   maxweight = maxweight + weight3
if(weight4 != 0) then
   maxweight = maxweight + weight4


if(maxweight != 0) then (
      if(weight1 != 0) then (
         w1 = weight1 as float
         append w.boneids (bone1 + 1)
         append w.weights (w1/255.0)
      )
      if(weight2 != 0) then (
         w2 = weight2 as float
         append w.boneids (bone2 + 1)
         append w.weights (w2/255.0)
      )
      if(weight3 != 0) then (
         w3 = weight3 as float
         append w.boneids (bone3 + 1)
         append w.weights (w3/255.0)
      )
      if(weight4 != 0) then (
         w4 = weight4 as float
         append w.boneids (bone4 + 1)
        append w.weights (w4/255.0)
      )      
   )
append Weight_array w		
)
)
)

if vert_info_array[8]!=undefined do (

fseek f vert_info_array[8] #seek_set
	
fseek f 0x4 #seek_cur
CType = (readlong f)
Count = readlong f	
Size = readlong f
fseek f 0x8 #seek_cur	

if ChunkOneType[8]==8 do (	
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*28)) #seek_set	
	
for x = 1 to VertexCountArray[i] do (
getPos = ftell f + 28
fseek f getPos #seek_set
)	
)

if ChunkOneType[8]==9 do 	(
	
VertOff=ftell f
fseek f (VertOff+(VertexEnd[i]*8)) #seek_set	
	
Print ("Weights Start @ 0x"+((bit.intAsHex(ftell f))as string))	
	
for x = 1 to VertexCountArray[i] do 
(
	
bone1 = readbyte f #unsigned	
bone2 = readbyte f #unsigned	
bone3 = readbyte f #unsigned	
bone4 = readbyte f #unsigned	
		
weight1 = readbyte f #unsigned	
weight2 = readbyte f #unsigned
weight3 = readbyte f #unsigned
weight4 = readbyte f #unsigned

w = (weight_data boneids:#() weights:#())
maxweight = 0
if(weight1 != 0) then
   maxweight = maxweight + weight1
if(weight2 != 0) then
   maxweight = maxweight + weight2
if(weight3 != 0) then
   maxweight = maxweight + weight3
if(weight4 != 0) then
   maxweight = maxweight + weight4


if(maxweight != 0) then (
      if(weight1 != 0) then (
         w1 = weight1 as float
         append w.boneids (bone1 + 1)
         append w.weights (w1/255.0)
      )
      if(weight2 != 0) then (
         w2 = weight2 as float
         append w.boneids (bone2 + 1)
         append w.weights (w2/255.0)
      )
      if(weight3 != 0) then (
         w3 = weight3 as float
         append w.boneids (bone3 + 1)
         append w.weights (w3/255.0)
      )
      if(weight4 != 0) then (
         w4 = weight4 as float
         append w.boneids (bone4 + 1)
        append w.weights (w4/255.0)
      )      
   )
append Weight_array w		
)
)
)

Print ("Weights End @ 0x"+((bit.intAsHex(ftell f))as string))

msh = mesh vertices:vertArray faces:Facearray
if ModelName2[i]!=undefined then (
msh.name = (ModelName2[i]+"_"+ i as string)	
)
if ModelName2[i]==undefined then (
msh.name = ("Model_"+ i as string)	
)
msh.numTVerts = UV_array.count
buildTVFaces msh
for j = 1 to UV_array.count do setTVert msh j UV_array[j]
for j = 1 to faceArray.count do setTVFace msh j faceArray[j]

move msh [-StrideX,-StrideY,StrideZ]
)

Print ("End @ 0x"+((bit.intAsHex(ftell f))as string))

fclose f
	
select objects
	