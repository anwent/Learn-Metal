//
//  Matrix.swift
//  Triangle
//
//  Created by zh on 2020/6/1.
//  Copyright © 2020 zh. All rights reserved.
//

import simd

class Matrix {
    
    var m: [Float]
    
    init() {
        m = [1, 0, 0, 0,
             0, 1, 0, 0,
             0, 0, 1, 0,
             0, 0, 0, 1]
    }
}

extension Matrix {
    
    func translationMatrix(_ position: vector_float3) -> Matrix {
        m[12] = m[12] + position.x
        m[13] = m[13] + position.y
        m[14] = m[14] + position.z
        return self
    }
    
    func scalingMatrix(_ scale: Float) -> Matrix {
        m[0] = m[0] * scale
        m[5] = m[5] * scale
        m[10] = m[15] * scale
        return self
    }

    func rotationZ(_ r: Float) -> Matrix {
        m[0] = cos(Float.pi / (180.0 / r))
        m[1] = sin(Float.pi / (180.0 / r))
        m[4] = (-1) * sin(Float.pi / (180.0 / r))
        m[5] = cos(Float.pi / (180.0 / r))
        return self
    }
    
}
