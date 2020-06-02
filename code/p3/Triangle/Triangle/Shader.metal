//
//  Shader.metal
//  Triangle
//
//  Created by zh on 2020/6/1.
//  Copyright © 2020 zh. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelMatrix;
};

vertex Vertex vertex_shader(constant Vertex *v [[buffer(0)]],
                            constant Uniforms &un [[buffer(1)]],
                            uint vid [[vertex_id]])
{
    float4x4 matrix = un.modelMatrix;
    Vertex in = v[vid];
    Vertex out;
    out.position = matrix * in.position;
    out.color = in.color;
    return out;
}

fragment float4 fragment_shader(Vertex v [[stage_in]])
{
    return v.color;
}
