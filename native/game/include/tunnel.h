#ifndef tunnel_h
#define tunnel_h

#include <dmsdk/sdk.h>

#include "game_base_userdata.h"


namespace d954masGame {

struct PlaneData {
  Vectormath::Aos::Vector3 p1,p2,p3,p4,normal,center,dir;
};

struct Segment {
    PlaneData* planes = NULL;
    size_t planesSize=0;
    Vectormath::Aos::Vector3 p1,p2,center;
     Segment() : planes(NULL),planesSize(0){}
};

class Tunnel  : public BaseUserData{
private:

public:
    Segment* segments = NULL;
    size_t segmentsSize = 0;
    Vectormath::Aos::Vector3* verticesPositions = NULL;
    size_t verticesPositionsSize = 0;

    dmBuffer::HBuffer buffer = NULL;
    int vertices = 0;
    float* bufferPositions = NULL;
    uint32_t  bufferPositionsStride;
    float* bufferTexture= NULL;
    uint32_t  bufferTextureStride;
    float* bufferColor= NULL;
    uint32_t  bufferColorStride;
    float* bufferNormal= NULL;
    uint32_t  bufferNormalStride;

    int angles = 4;
    float planeSize=0;
    float startAngle=0;

    Tunnel();
    virtual ~Tunnel();
    virtual void Destroy(lua_State *L);

    bool BufferIsValid();
    void SetPoints(Vectormath::Aos::Vector3 * points, size_t count);
    void SetAngles(size_t angles);
    void SetPlaneSize(float planeSize);
    void SetPlaneColor(int segmentIdx, int planeIdx, float r, float g, float b, float a);


};

void TunnelInitMetaTable(lua_State *L);
Tunnel* Tunnel_get_userdata_safe(lua_State *L, int index);

}
#endif