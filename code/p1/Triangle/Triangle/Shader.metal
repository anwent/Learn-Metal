//
//  Shader.metal
//  Triangle
//
//  Created by zh on 2020/6/1.
//  Copyright © 2020 zh. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


vertex float4 vertex_shader(constant packed_float3 *vertex_array[[buffer(0)]],
                           unsigned int vid[[vertex_id]])
{
    return float4(vertex_array[vid], 1.0f);
}


fragment float4 fragment_shader()
{
    return float4(0.1f, 0.3f, 0.6f, 1.0f);
}
