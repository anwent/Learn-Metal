//
//  Vertex.h
//  Texture
//
//  Created by zh on 2020/6/4.
//  Copyright © 2020 zh. All rights reserved.
//

#ifndef Vertex_h
#define Vertex_h

#include <simd/simd.h>

typedef struct
{
    vector_float2 position;
    vector_float2 textureCoordinate;
} Vertex;

#endif /* Vertex_h */
