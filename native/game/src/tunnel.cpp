#include "tunnel.h"
#include "game_utils.h"
#include <math.h>
#include <algorithm>

#define META_NAME "Game::TunnelClass"
#define USERDATA_TYPE "Tunnel"

#define TWO_PI  6.28318530717958648f
#define PI   3.14159265358979323846

static inline bool FloatEquals(float a, float b){
    return fabs(a - b) < 0.01f;
}


namespace d954masGame {


Tunnel::Tunnel():  BaseUserData(USERDATA_TYPE){
    this->metatable_name = META_NAME;
    this->obj = this;
}

Tunnel::~Tunnel() {
    if(this->segments != NULL){
        for(int i=0;i<this->segmentsSize;i++){
            Segment *s = &this->segments[i];
            if(s->planes != NULL){
                delete[] s->planes;
                s->planes = NULL;
            }
        }
        delete[] this->segments;
        this->segments = NULL;
    }
    if(this->verticesPositions != NULL){
        delete[] this->verticesPositions;
        this->verticesPositions = NULL;
    }
    if(this->buffer != NULL){
        dmBuffer::Destroy(buffer);
        this->buffer = NULL;
    }
}


Tunnel* Tunnel_get_userdata_safe(lua_State *L, int index) {
    Tunnel *lua_obj = (Tunnel*) BaseUserData_get_userdata(L, index, USERDATA_TYPE);
    return lua_obj;
}

const dmBuffer::StreamDeclaration streams_decl[] = {
    {dmHashString64("position"), dmBuffer::VALUE_TYPE_FLOAT32, 3},
    {dmHashString64("normal"), dmBuffer::VALUE_TYPE_FLOAT32, 3},
    {dmHashString64("texcoord0"), dmBuffer::VALUE_TYPE_FLOAT32, 2},
    {dmHashString64("color0"), dmBuffer::VALUE_TYPE_FLOAT32, 4},
};

bool Tunnel::BufferIsValid() {
    dmBuffer::Result r = dmBuffer::ValidateBuffer(buffer);
    return r == dmBuffer::RESULT_OK;
}

static void inline bufferSetPositions(Tunnel* t, float* posIter,
        Vectormath::Aos::Vector3& p1,Vectormath::Aos::Vector3& p2,
        Vectormath::Aos::Vector3& p3,Vectormath::Aos::Vector3& p4){

    posIter[0] = p1.getX();
    posIter[1] = p1.getY();
    posIter[2] = p1.getZ();

    posIter += t->bufferPositionsStride;
    posIter[0] = p2.getX();
    posIter[1] = p2.getY();
    posIter[2] = p2.getZ();

    posIter += t->bufferPositionsStride;
    posIter[0] = p4.getX();
    posIter[1] = p4.getY();
    posIter[2] = p4.getZ();

    posIter += t->bufferPositionsStride;
    posIter[0] = p1.getX();
    posIter[1] = p1.getY();
    posIter[2] = p1.getZ();

    posIter += t->bufferPositionsStride;
    posIter[0] = p4.getX();
    posIter[1] = p4.getY();
    posIter[2] = p4.getZ();

    posIter += t->bufferPositionsStride;
    posIter[0] = p3.getX();
    posIter[1] = p3.getY();
    posIter[2] = p3.getZ();
}

static void inline bufferSetTexture(Tunnel* t, float* iter){
    iter[0] = 0;
    iter[1] = 0;

    iter += t->bufferTextureStride;
    iter[0] = 1;
    iter[1] = 0;

    iter += t->bufferTextureStride;
    iter[0] = 1;
    iter[1] = 1;

    iter += t->bufferTextureStride;
    iter[0] = 0;
    iter[1] = 0;

    iter += t->bufferTextureStride;
    iter[0] = 1;
    iter[1] = 1;

    iter += t->bufferTextureStride;
    iter[0] = 0;
    iter[1] = 1;
}

static void inline bufferSetColor(Tunnel* t, float* iter, float r, float g, float b, float a){
    iter[0] = r;
    iter[1] = g;
    iter[2] = b;
    iter[3] = a;

    iter += t->bufferColorStride;
    iter[0] = r;
    iter[1] = g;
    iter[2] = b;
    iter[3] = a;

    iter += t->bufferColorStride;
    iter[0] = r;
    iter[1] = g;
    iter[2] = b;
    iter[3] = a;

    iter += t->bufferColorStride;
    iter[0] = r;
    iter[1] = g;
    iter[2] = b;
    iter[3] = a;

    iter += t->bufferColorStride;
    iter[0] = r;
    iter[1] = g;
    iter[2] = b;
    iter[3] = a;

    iter += t->bufferColorStride;
    iter[0] = r;
    iter[1] = g;
    iter[2] = b;
    iter[3] = a;
}

static void inline bufferSetNormal(Tunnel* t, float* iter,Vectormath::Aos::Vector3& normal){

    iter[0] = normal.getX();
    iter[1] = normal.getY();
    iter[2] = normal.getZ();

    iter += t->bufferNormalStride;
    iter[0] = normal.getX();
    iter[1] = normal.getY();
    iter[2] = normal.getZ();

    iter += t->bufferNormalStride;
    iter[0] = normal.getX();
    iter[1] = normal.getY();
    iter[2] = normal.getZ();

    iter += t->bufferNormalStride;
    iter[0] = normal.getX();
    iter[1] = normal.getY();
    iter[2] = normal.getZ();

    iter += t->bufferNormalStride;
    iter[0] = normal.getX();
    iter[1] = normal.getY();
    iter[2] = normal.getZ();

    iter += t->bufferNormalStride;
    iter[0] = normal.getX();
    iter[1] = normal.getY();
    iter[2] = normal.getZ();
}

void Tunnel::SetPoints(Vectormath::Aos::Vector3 * points, size_t count) {
  //dmLogWarning("SET POINTS_1");
    //if(this->segments!=NULL){return;}
    //  dmLogWarning("SET POINTS BUFFER");
    if(this->buffer == NULL){
     this->vertices = 6 * this->angles * (count-1);
        dmBuffer::Result bufferResult = dmBuffer::Create((this->vertices), streams_decl, 4, &buffer);
        if (bufferResult == dmBuffer::RESULT_OK) {

        } else {
            dmLogError("can't create buffer");
            return;
        }

        dmBuffer::Result possitionResult = dmBuffer::GetStream(this->buffer, dmHashString64("position"),
                        (void**)&this->bufferPositions, NULL, NULL, &this->bufferPositionsStride);
        if (possitionResult != dmBuffer::RESULT_OK) {
            dmLogError("can't get buffer position");
        }

        dmBuffer::Result textureResult = dmBuffer::GetStream(this->buffer, dmHashString64("texcoord0"),
                        (void**)&this->bufferTexture, NULL, NULL, &this->bufferTextureStride);
        if (textureResult != dmBuffer::RESULT_OK) {
            dmLogError("can't get buffer texture");
        }

        dmBuffer::Result colorResult = dmBuffer::GetStream(this->buffer, dmHashString64("color0"),
                        (void**)&this->bufferColor, NULL, NULL, &this->bufferColorStride);
        if (colorResult != dmBuffer::RESULT_OK) {
            dmLogError("can't get buffer color0");
        }

        dmBuffer::Result normalResult = dmBuffer::GetStream(this->buffer, dmHashString64("normal"),
                        (void**)&this->bufferNormal, NULL, NULL, &this->bufferNormalStride);
        if (normalResult != dmBuffer::RESULT_OK) {
            dmLogError("can't get buffer normal");
        }
    }


  //dmLogWarning("SET POLYGON VERTICES");
    Vectormath::Aos::Vector3* polygon_vertices = new Vectormath::Aos::Vector3[this->angles];

    float d_angle = (TWO_PI / this->angles);
    float r_out = this->planeSize / (2 * sin(PI / this->angles));
    float r = r_out;

    Vectormath::Aos::Vector3 p1(r * cos(0),r * sin(0),0);
    Vectormath::Aos::Vector3 p2(r * cos(d_angle),r * sin(d_angle),0);
    p2 = Vectormath::Aos::normalize(p2 - p1);
    Vectormath::Aos::Vector3 pdir(1,0,0);

    //not correct
   // float start_angle =  -atan2(p2.getY() - pdir.getY(), p2.getX() - pdir.getX()) + d_angle;

     for (int i=0; i<this->angles; i++) {
    	float angle_vert = this->startAngle+i * d_angle;
    	float x = r * cos(angle_vert);
    	float y = r * sin(angle_vert);
    	Vectormath::Aos::Vector3* polygon = &polygon_vertices[i];
    	polygon->setX(x);
    	polygon->setY(y);
    	polygon->setZ(0);

    }

    if(this->verticesPositions == NULL){
        this->verticesPositionsSize = count * this->angles;
        this->verticesPositions = new Vectormath::Aos::Vector3[this->verticesPositionsSize];
    }

 //dmLogWarning("SET verticesPositions");

    Vectormath::Aos::Vector3 rotated_vertex;
    Vectormath::Aos::Vector3 forward_v(0,0,-1);
    for (int i=0; i<count; i++) {
        Vectormath::Aos::Vector3 p1 = points[i];
        Vectormath::Aos::Vector3 dir;
        if(i+1>=count){
           dir =  Vectormath::Aos::normalize(p1 - points[i-1]);//p1 - points[i-1];
        }else{
            dir = Vectormath::Aos::normalize(points[i+1]-p1);
        }
        Vectormath::Aos::Quat q = Vectormath::Aos::Quat::rotation(forward_v, dir);
       // Vectormath::Aos::Quat q = Vectormath::Aos::Quat::rotationZ(1);
        for (int j=0;j<this->angles;j++){
          //  rotated_vertex = Vectormath::Aos::rotate(q, polygon_vertices[j]);
            rotated_vertex =  polygon_vertices[j];
            this->verticesPositions[i*this->angles+j] = p1 + rotated_vertex;
         // this->verticesPositions[i*this->angles+j] = p1 + polygon_vertices[j];
        }
    }

    if(this->segments==NULL){
        segmentsSize = count-1;
        segments = new Segment[count-1];
    }

   // dmLogWarning("SET main");
    for (int i=0; i<count-1; i++) {
    // dmLogWarning("SET main %d",i);
        Vectormath::Aos::Vector3 p1 = points[i];
        Vectormath::Aos::Vector3 p2= points[i+1];

        Segment* s1 = &segments[i];
        s1->p1 =  points[i];
        s1->p2 =  points[i+1];
        s1->center =points[i]+ (points[i+1]-points[i])/2;
        s1->planesSize = this->angles;
       //  dmLogWarning("SET planes");
        if(s1->planes == NULL){
            s1->planes = new PlaneData[s1->planesSize];
        }
     //    dmLogWarning("SET planes done");

        for(int j=0;j<this->angles;j++){
            int idxNext = j+1;
            if(idxNext >= this->angles){
               idxNext = 0;
            }
            PlaneData* plane1 = &s1->planes[j];

            plane1->p1 = this->verticesPositions[i*this->angles+j];
            plane1->p2 = this->verticesPositions[i*this->angles+idxNext];
            plane1->p3 = this->verticesPositions[(i+1)*this->angles+j];
            plane1->p4 = this->verticesPositions[(i+1)*this->angles+idxNext];
         //   plane1->p1 = p1 + polygon_vertices[j];
          //  plane1->p2 = p1 + polygon_vertices[idxNext];
           // plane1->p3 = p2 + polygon_vertices[j];
            //plane1->p4 = p2 + polygon_vertices[idxNext];
            plane1->center = plane1->p1+(plane1->p4 - plane1->p1) / 2;
            plane1->dir = Vectormath::Aos::normalize(plane1->p3 - plane1->p1);
            plane1->normal = Vectormath::Aos::normalize(Vectormath::Aos::cross(
                plane1->p2 -  plane1->p1,  plane1->p3 -  plane1->p1)
            );

            int bufferIdx = (i*this->angles+j)*6;
            float* posIter = &this->bufferPositions[bufferIdx*this->bufferPositionsStride];
            float* textureIter = &this->bufferTexture[bufferIdx*this->bufferTextureStride];
            float* colorIter = &this->bufferColor[bufferIdx*this->bufferColorStride];
            float* normalIter = &this->bufferNormal[bufferIdx*this->bufferNormalStride];


            bufferSetPositions(this,posIter,plane1->p1,plane1->p2,plane1->p3,plane1->p4);
            bufferSetTexture(this,textureIter);
            bufferSetColor(this,colorIter,1,1,1,1.0);
            bufferSetNormal(this,normalIter,plane1->normal);
        }
    }
    //dmLogWarning("set main DONE");
     dmBuffer::UpdateContentVersion(this->buffer);
    delete[] polygon_vertices;
}

void Tunnel::SetAngles(size_t angles){
    if(this->segments!=NULL){return;}
    if(angles<3){
       dmLogError("Angle should be bigger 3 get:%d",angles);
        return;
    }
    this->angles = angles;
}
void Tunnel::SetPlaneSize(float size){
    if(this->segments!=NULL){return;}
    if(size<0){
        dmLogError("Size should be bigger 0 get:%f",size);
        return;
    }
    this->planeSize = size;
}
void Tunnel::SetPlaneColor(int segmentIdx, int planeIdx, float r, float g, float b, float a){
    if(this->buffer==NULL){return;}
    if(segmentIdx<0 || segmentIdx >= this->segmentsSize){
        dmLogError("Bad segment idx:%d",segmentIdx);
        return;
    }
    if(planeIdx<0 || planeIdx >= this->angles){
        dmLogError("Bad plane idx:%f",planeIdx);
        return;
    }
    int bufferIdx = (segmentIdx*this->angles+planeIdx)*6;
    float* colorIter = &this->bufferColor[bufferIdx*this->bufferColorStride];
    bufferSetColor(this,colorIter,1,g,b,a);
    dmBuffer::UpdateContentVersion(this->buffer);
}


void Tunnel::Destroy(lua_State *L) {
    BaseUserData::Destroy(L);
}



static int BufferGetContentVersion(lua_State *L){
    d954masGameUtils::check_arg_count(L, 1);
    Tunnel *tunnel = Tunnel_get_userdata_safe(L, 1);
    uint32_t version = 0;
    dmBuffer::Result result = dmBuffer::GetContentVersion(tunnel->buffer, &version);
    lua_pushnumber(L, version);
    return 1;
};

static int BufferIsValid(lua_State *L){
    d954masGameUtils::check_arg_count(L, 1);
    Tunnel *tunnel = Tunnel_get_userdata_safe(L, 1);
    lua_pushboolean(L, tunnel->BufferIsValid());
    return 1;
};


static int Destroy(lua_State *L) {
    d954masGameUtils::check_arg_count(L, 1);
    Tunnel *tunnel = Tunnel_get_userdata_safe(L, 1);
    tunnel->Destroy(L);
    delete tunnel;
    return 0;
}


static int ToString(lua_State *L){
    d954masGameUtils::check_arg_count(L, 1);
    Tunnel *lua_tunnel = Tunnel_get_userdata_safe(L, 1);
    lua_pushfstring( L, "Tunnel[%p]",(void *) lua_tunnel);
	return 1;
}


static int GetBuffer(lua_State *L){
    d954masGameUtils::check_arg_count(L, 1);
    Tunnel *lua_tunnel = Tunnel_get_userdata_safe(L, 1);
    dmScript::LuaHBuffer luabuffer = { lua_tunnel->buffer, dmScript::OWNER_C };
    PushBuffer(L, luabuffer);
	return 1;
}

static int SetAngles(lua_State *L){
    d954masGameUtils::check_arg_count(L, 2);
    Tunnel *lua_tunnel = Tunnel_get_userdata_safe(L, 1);
    lua_tunnel->SetAngles(lua_tonumber(L,2));
	return 0;
}

static int SetStartAngle(lua_State *L){
    d954masGameUtils::check_arg_count(L, 2);
    Tunnel *lua_tunnel = Tunnel_get_userdata_safe(L, 1);
    lua_tunnel->startAngle = lua_tonumber(L,2);
	return 0;
}


static int SetPlaneSize(lua_State *L){
    d954masGameUtils::check_arg_count(L, 2);
    Tunnel *lua_tunnel = Tunnel_get_userdata_safe(L, 1);
    lua_tunnel->SetPlaneSize(lua_tonumber(L,2));
	return 0;
}

static int SetPlaneColor(lua_State *L){
    d954masGameUtils::check_arg_count(L, 7);
    Tunnel *lua_tunnel = Tunnel_get_userdata_safe(L, 1);
    int segmentIdx = luaL_checknumber(L, 2);
    int planeIdx = luaL_checknumber(L, 3);
    float r = luaL_checknumber(L, 4);
    float g = luaL_checknumber(L, 5);
    float b = luaL_checknumber(L, 6);
    float a = luaL_checknumber(L, 7);
    lua_tunnel->SetPlaneColor(segmentIdx,planeIdx,r,g,b,a);
	return 0;
}

static int SetPoints(lua_State *L){
   // dmLogWarning("SET POINTS");
    d954masGameUtils::check_arg_count(L, 2);
    Tunnel *lua_tunnel = Tunnel_get_userdata_safe(L, 1);
    if (!lua_istable(L, 2)) {
        luaL_error(L, "Need table with points");
    }
    int n = luaL_getn(L, 2);  /* get size of table */
    if (n<2) {
        luaL_error(L, "Need at least 2 points");
    }
    Vectormath::Aos::Vector3* vectors = new Vectormath::Aos::Vector3[n];
    for (int i=1; i<=n; i++) {
        lua_rawgeti(L, 2, i); //get entity
        Vectormath::Aos::Vector3 *point = dmScript::CheckVector3(L, -1);
        vectors[i-1] = *point;
        lua_pop(L,1);
    }
    lua_tunnel->SetPoints(vectors,n);
  //   dmLogWarning("SET POINTS done");

    delete[] vectors;


	return 0;
}



static int SetPlanesRandomColors(lua_State *L){
    d954masGameUtils::check_arg_count(L, 1);
    Tunnel *obj = Tunnel_get_userdata_safe(L, 1);

    //int range = obj->angles; //int range = max - min + 1;  obj->angles - 1 - 0 + 1
    //int num = rand() % range + 0;
    //( value % 100 ) is in the range 0 to 99
    for (int i=0; i<obj->segmentsSize; i++) {
        obj->SetPlaneColor(i,rand()%obj->angles, 1, 0.9, 0.9, 1);
        obj->SetPlaneColor(i,rand()%obj->angles, 0.9, 1, 0.9, 1);
        obj->SetPlaneColor(i,rand()%obj->angles, 0.95, 1, 0.9, 1);
    }
     dmBuffer::UpdateContentVersion(obj->buffer);
	return 0;
}

static int GetTunnelInfo(lua_State *L){
    d954masGameUtils::check_arg_count(L, 1);
    Tunnel *obj = Tunnel_get_userdata_safe(L, 1);
    lua_newtable(L);

    //lua_pushnumber(L,obj->segmentsSize);
    //lua_setfield(L, -2, "segments");

    lua_pushnumber(L,obj->angles);
    lua_setfield(L, -2, "planes");

    /*lua_newtable(L);
     for (int i=0; i<obj->verticesPositionsSize; i++) {
        dmScript::PushVector3(L, obj->verticesPositions[i]);
        lua_rawseti(L, -2,i+1);
    }
    lua_setfield(L, -2, "vertices");*/

    lua_newtable(L);
    for (int i=0; i<obj->segmentsSize; i++) {
        Segment *s = &obj->segments[i];
        lua_newtable(L);

        lua_newtable(L);
        for (int j=0; j<obj->angles; j++) {
            PlaneData *p = &s->planes[j];
            lua_newtable(L);
            dmScript::PushVector3(L, p->p1);
            lua_setfield(L, -2, "p1");
            dmScript::PushVector3(L, p->p2);
            lua_setfield(L, -2, "p2");
            dmScript::PushVector3(L, p->p3);
            lua_setfield(L, -2, "p3");
            dmScript::PushVector3(L, p->p4);
            lua_setfield(L, -2, "p4");
            dmScript::PushVector3(L, p->center);
            lua_setfield(L, -2, "center");
            dmScript::PushVector3(L, p->normal);
            lua_setfield(L, -2, "normal");


            lua_rawseti(L, -2,j+1);
        }
        lua_setfield(L, -2, "planes");

        lua_rawseti(L, -2,i+1);
    }
    lua_setfield(L, -2, "segments");

    return 1;
}

static int UpdateTunnelInfo(lua_State *L){
    d954masGameUtils::check_arg_count(L, 2);
    Tunnel *obj = Tunnel_get_userdata_safe(L, 1);
    if(!lua_istable(L,2)){
       luaL_error(L, "2 arg should be table"); \
    }

     /*lua_getfield(L, -1, "vertices");
     for (int i=0; i<obj->verticesPositionsSize; i++) {
        lua_rawgeti(L, -1,i+1);
        dmScript::PushVector3(L, obj->verticesPositions[i]);
    }
    lua_setfield(L, -2, "vertices");*/

    lua_getfield(L, -1, "segments");
    for (int i=0; i<obj->segmentsSize; i++) {
        Segment *s = &obj->segments[i];
        lua_rawgeti(L, -1,i+1);
        lua_getfield(L, -1, "planes");
        for (int j=0; j<obj->angles; j++) {
            PlaneData *p = &s->planes[j];
            lua_rawgeti(L, -1,j+1);

            lua_getfield(L, -1, "p1");
            Vectormath::Aos::Vector3 *out = dmScript::CheckVector3(L, -1);
            *out = (p->p1);
            lua_pop(L,1);

            lua_getfield(L, -1, "p2");
            out = dmScript::CheckVector3(L, -1);
            *out = (p->p2);
            lua_pop(L,1);

            lua_getfield(L, -1, "p3");
            out = dmScript::CheckVector3(L, -1);
            *out = (p->p3);
            lua_pop(L,1);

            lua_getfield(L, -1, "p4");
            out = dmScript::CheckVector3(L, -1);
            *out = (p->p4);
            lua_pop(L,1);

            lua_getfield(L, -1, "center");
            out = dmScript::CheckVector3(L, -1);
            *out = (p->center);
            lua_pop(L,1);

            lua_getfield(L, -1, "normal");
            out = dmScript::CheckVector3(L, -1);
            *out = (p->normal);
            lua_pop(L,1);

            /*dmScript::PushVector3(L, p->p1);
            lua_setfield(L, -2, "p1");
            dmScript::PushVector3(L, p->p2);
            lua_setfield(L, -2, "p2");
            dmScript::PushVector3(L, p->p3);
            lua_setfield(L, -2, "p3");
            dmScript::PushVector3(L, p->p4);
            lua_setfield(L, -2, "p4");
            dmScript::PushVector3(L, p->center);
            lua_setfield(L, -2, "center");
            dmScript::PushVector3(L, p->normal);
            lua_setfield(L, -2, "normal");*/
            lua_pop(L,1);
        }
        lua_pop(L,1);
        lua_pop(L,1);
    }
    lua_pop(L,1);

    return 1;
}

static inline Segment* _GetSegmentData(lua_State *L){
    d954masGameUtils::check_arg_count(L, 2);
    Tunnel *obj = Tunnel_get_userdata_safe(L, 1);
    int segment = luaL_checknumber(L,2);
    if(segment<0 || segment >=obj->segmentsSize ){
        luaL_error(L, "Bad segment:%d.", segment);
    }
    Segment *s = &obj->segments[segment];
    return s;
}

static inline PlaneData* _GetPlaneData(lua_State *L){
    d954masGameUtils::check_arg_count(L, 3);
    Tunnel *obj = Tunnel_get_userdata_safe(L, 1);
    int segment = luaL_checknumber(L,2);
    if(segment<0 || segment >=obj->segmentsSize ){
        luaL_error(L, "Bad segment:%d.", segment);
    }
    int plane = luaL_checknumber(L,3);
    if(plane<0 || plane >=obj->angles ){
        luaL_error(L, "Bad plane:%d.", plane);
    }
    Segment *s = &obj->segments[segment];
    PlaneData *p = &s->planes[plane];
    return p;
}

static int GetSegmentP1(lua_State *L){
    Segment *s = _GetSegmentData(L);
    lua_pushnumber(L,s->p1.getX());
    lua_pushnumber(L,s->p1.getY());
    lua_pushnumber(L,s->p1.getZ());
	return 3;
}

static int GetSegmentP2(lua_State *L){
    Segment *s = _GetSegmentData(L);
    lua_pushnumber(L,s->p2.getX());
    lua_pushnumber(L,s->p2.getY());
    lua_pushnumber(L,s->p2.getZ());
	return 3;
}

static int GetSegmentCenter(lua_State *L){
    Segment *s = _GetSegmentData(L);
    lua_pushnumber(L,s->center.getX());
    lua_pushnumber(L,s->center.getY());
    lua_pushnumber(L,s->center.getZ());
	return 3;
}

static int GetPlaneP1(lua_State *L){
    PlaneData *p = _GetPlaneData(L);
    lua_pushnumber(L,p->p1.getX());
    lua_pushnumber(L,p->p1.getY());
    lua_pushnumber(L,p->p1.getZ());
	return 3;
}
static int GetPlaneP2(lua_State *L){
    PlaneData *p = _GetPlaneData(L);
    lua_pushnumber(L,p->p2.getX());
    lua_pushnumber(L,p->p2.getY());
    lua_pushnumber(L,p->p2.getZ());
	return 3;
}
static int GetPlaneP3(lua_State *L){
    PlaneData *p = _GetPlaneData(L);
    lua_pushnumber(L,p->p3.getX());
    lua_pushnumber(L,p->p3.getY());
    lua_pushnumber(L,p->p3.getZ());
	return 3;
}
static int GetPlaneP4(lua_State *L){
    PlaneData *p = _GetPlaneData(L);
    lua_pushnumber(L,p->p4.getX());
    lua_pushnumber(L,p->p4.getY());
    lua_pushnumber(L,p->p4.getZ());
	return 3;
}
static int GetPlaneNormal(lua_State *L){
    PlaneData *p = _GetPlaneData(L);
    lua_pushnumber(L,p->normal.getX());
    lua_pushnumber(L,p->normal.getY());
    lua_pushnumber(L,p->normal.getZ());
	return 3;
}
static int GetPlaneCenter(lua_State *L){
    PlaneData *p = _GetPlaneData(L);
    lua_pushnumber(L,p->center.getX());
    lua_pushnumber(L,p->center.getY());
    lua_pushnumber(L,p->center.getZ());
	return 3;
}

static int GetPlaneDir(lua_State *L){
    PlaneData *p = _GetPlaneData(L);
    lua_pushnumber(L,p->dir.getX());
    lua_pushnumber(L,p->dir.getY());
    lua_pushnumber(L,p->dir.getZ());
	return 3;
}

void TunnelInitMetaTable(lua_State *L){
    int top = lua_gettop(L);

    luaL_Reg functions[] = {
        {"BufferGetContentVersion",BufferGetContentVersion},
        {"BufferIsValid",BufferIsValid},
        {"GetBuffer",GetBuffer},
        {"SetAngles",SetAngles},
        {"SetStartAngle",SetStartAngle},
        {"SetPoints",SetPoints},
        {"SetPlaneSize",SetPlaneSize},
        {"SetPlaneColor",SetPlaneColor},
        {"SetPlanesRandomColors",SetPlanesRandomColors},
        {"GetTunnelInfo",GetTunnelInfo},
        {"UpdateTunnelInfo",UpdateTunnelInfo},
        {"GetSegmentP1",GetSegmentP1},
        {"GetSegmentP2",GetSegmentP2},
        {"GetSegmentCenter",GetSegmentCenter},
        {"GetPlaneP1",GetPlaneP1},
        {"GetPlaneP2",GetPlaneP2},
        {"GetPlaneP3",GetPlaneP3},
        {"GetPlaneP4",GetPlaneP4},
        {"GetPlaneNormal",GetPlaneNormal},
        {"GetPlaneCenter",GetPlaneCenter},
        {"GetPlaneDir",GetPlaneDir},
        {"Destroy",Destroy},
        {"__tostring",ToString},
        { 0, 0 }
    };
    luaL_newmetatable(L, META_NAME);
    luaL_register (L, NULL,functions);
    lua_pushvalue(L, -1);
    lua_setfield(L, -1, "__index");
    lua_pop(L, 1);


    assert(top == lua_gettop(L));
}





}


