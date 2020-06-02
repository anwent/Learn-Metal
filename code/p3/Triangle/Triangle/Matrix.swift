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
        
        // c++ row-major order
        // print(m)  =>  [1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
    }
    
    
    /*
     
     平移
     
     | 1     0     0    Tx |
     | 0     1     0    Ty |
     | 0     0     1    Tz |
     | 0     0     0     1 |
     
     */
//    func translationMatrix(_ matrix: inout Matrix, position: vector_float3) -> Matrix {
//        matrix.m[12] = position.x
//        matrix.m[13] = position.y
//        matrix.m[14] = position.z
//        return matrix
//    }
//
//    /*
//     缩放
//     | Sx    0     0     0 |
//     | 0     Sy    0     0 |
//     | 0     0     Sz    0 |
//     | 0     0     0     1 |
//     */
//    func scalingMatrix(_ matrix: inout Matrix, scale: Float) -> Matrix {
//        matrix.m[0] = scale
//        matrix.m[5] = scale
//        matrix.m[10] = scale
//        return matrix
//    }
    
    
    
    // 变换
//    func modelMatrix(_ matrix: Matrix) -> Matrix {
//        var mat = matrix
////        mat = translationMatrix(&mat, position: vector_float3(0.5, 0.5, 0.0))
//        mat = scalingMatrix(&mat, scale: 0.1)
//
//        mat = translationMatrix(&mat, position: vector_float3(0.5, 0.5, 1.0))
//
//        return mat
//    }
}

extension Matrix {
    
    func translationMatrix(_ position: vector_float3) -> Self {
        m[12] = position.x
        m[13] = position.y
        m[14] = position.z
        return self
    }
    
    func scalingMatrix(_ scale: Float) -> Self {
        m[0] = scale
        m[5] = scale
        m[10] = scale
        return self
    }
    
}
