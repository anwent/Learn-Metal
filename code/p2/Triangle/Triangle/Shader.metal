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

//  [[vertex_id]]是通信中使用的每个顶点标识符。Metal使用顶点函数的输出和光栅化器生成的片段，生成片段函数的每个片段输入。每片段输入由[[stage_in]]属性限定符标识。
vertex Vertex vertex_shader(constant Vertex *v [[buffer(0)]],
                            uint vid[[vertex_id]])
{
    return v[vid];
}

fragment float4 fragment_shader(Vertex v [[stage_in]])
{
    return v.color;
}
