//
//  Shader.metal
//  Texture
//
//  Created by zh on 2020/6/4.
//  Copyright © 2020 zh. All rights reserved.
//

#include <metal_stdlib>
#include "Vertex.h"
using namespace metal;

typedef struct
{
    float4 position [[position]];
    float2 textureCoordinate;
    
} RasterizerData;


vertex RasterizerData vertex_shader(uint vid [[vertex_id]],
                                    constant Vertex *vertex_array [[buffer(0)]],
                                    constant vector_uint2 *viewportSizePointer [[buffer(1)]])
{
    
    RasterizerData out;
    
    float2 pixelSpacePosition = vertex_array[vid].position.xy;
    float2 viewportSize = float2(*viewportSizePointer);
    // 初始化 position
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    out.textureCoordinate = vertex_array[vid].textureCoordinate;
    
    return out;
    
}

fragment float4 fragment_shader(RasterizerData in [[stage_in]],
                                texture2d<half> colorTexture [[texture(0)]])
{
    
    constexpr sampler textureSampler (mag_filter::linear,
                                      min_filter::linear);
    const half4 colorSampler = colorTexture.sample(textureSampler, in.textureCoordinate);
    return float4(colorSampler);
    
}
