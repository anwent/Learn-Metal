//
//  Shader.metal
//  Camera
//
//  Created by zh on 2020/6/4.
//  Copyright © 2020 zh. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 position [[position]];
    float2 uv;
} Vertex;

vertex Vertex vertex_shader(unsigned int vid [[vertex_id]])
{
    
    //    float4x4 vertex_coordinates = float4x4(
    //                                           float4(-1.0, -1.0, 0.0, 1.0),
    //                                           float4(1.0,  -1.0, 0.0, 1.0),
    //                                           float4(-1.0,  1.0, 0.0, 1.0),
    //                                           float4(1.0,   1.0, 0.0, 1.0)
    //                                           );
    
    float4x4 vertex_coordinates = float4x4(
                                           float4(-1.0, 0.0, 0.0, 1.0),
                                           float4(0.0,  -1.0, 0.0, 1.0),
//                                           float4(1.0,  0.0, 0.0, 1.0),
                                           float4(0.0,   1.0, 0.0, 1.0),
                                           float4(1.0,  0.0, 0.0, 1.0)
                                           );
    
    //    float4x2 uv_coordinates = float4x2(
    //                                       float2(0, 1),
    //                                       float2(1, 1),
    //                                       float2(0, 0),
    //                                       float2(1, 0)
    //                                       );
    
    float4x2 uv_coordinates = float4x2(
                                       float2(0.0, 0.5),
                                       float2(0.5, 1.0),
//                                       float2(1.0, 0.5),
                                       float2(0.5, 0.0),
                                       float2(1.0, 0.5)
                                       );
    
    Vertex out;
    out.position = vertex_coordinates[vid];
    out.uv = uv_coordinates[vid];
    return out;
}


fragment half4 fragment_shader(Vertex v [[stage_in]],
                               texture2d<float, access::sample> texture [[texture(0)]])
{
    constexpr sampler s(address::clamp_to_edge,
                        filter::linear);
    return half4(texture.sample(s, v.uv));
}
