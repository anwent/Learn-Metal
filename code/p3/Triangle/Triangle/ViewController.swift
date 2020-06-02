//
//  ViewController.swift
//  Triangle
//
//  Created by zh on 2020/6/1.
//  Copyright © 2020 zh. All rights reserved.
//

import UIKit
import MetalKit

struct Vertex {
    var position: vector_float4
    var color: vector_float4
}

class ViewController: UIViewController {
    
    var device: MTLDevice? = nil
    
    var metalLayer: CAMetalLayer! = nil
    
    var vertexBuffer: MTLBuffer?
    var uniformBuffer: MTLBuffer?
    
    var pipelineState: MTLRenderPipelineState?
    
    var commandQueue: MTLCommandQueue?
    
    var commandBuffer: MTLCommandBuffer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        p1_createDevice()
        p2_createLayer()
        p3_createVertexBuffer()
        // p4 顶点着色器
        // p5 片段着色器
        p6_createRenderPipeline()
        p7_createCommandQueue()
        
        start_rendering()
        
    }
    
}



extension ViewController {
    
    private func p1_createDevice() {
        device = MTLCreateSystemDefaultDevice()
    }
    
    private func p2_createLayer() {
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.frame = view.layer.frame
        
        view.layer.addSublayer(metalLayer)
    }
    
    private func p3_createVertexBuffer() {
        
        let vertexData: [Vertex] = [Vertex(position: [0.0, 0.25, 0.0, 1.0], color: [1, 0, 0, 1]),
                                    Vertex(position: [-0.25, -0.25, 0.0, 1.0], color: [0, 1, 0, 1]),
                                    Vertex(position: [0.25, -0.25, 0.0, 1.0], color: [0, 0, 1, 1])]
        vertexBuffer = device?.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Vertex>.size, options: [])
        
        
        let mat = Matrix().rotationZ(90)
        


//        uniformBuffer = device?.makeBuffer(length: MemoryLayout<Float>.size * 16, options: [])
//        let bufferPointer = uniformBuffer?.contents()
//        memcpy(bufferPointer!, mat.m, MemoryLayout<Float>.size * 16)
        
        uniformBuffer = device?.makeBuffer(bytes: mat.m,
                                           length: MemoryLayout<Float>.size * 16,
                                           options: [])
        
    }
    
    private func p6_createRenderPipeline() {
        
        let defaultLibrary = device?.makeDefaultLibrary()
        let fragmentFunc = defaultLibrary?.makeFunction(name: "fragment_shader")
        let vertexFunc = defaultLibrary?.makeFunction(name: "vertex_shader")

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.fragmentFunction = fragmentFunc
        pipelineStateDescriptor.vertexFunction = vertexFunc
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        
        
        do {
            pipelineState = try device?.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        } catch let error {
            print("pipelineState Error: ", error)
        }
    }
    
    private func p7_createCommandQueue() {
        commandQueue = device?.makeCommandQueue()
        
    }
    
    /// 开始渲染
    private func start_rendering() {

        let drawable = metalLayer.nextDrawable()
        let rpd = MTLRenderPassDescriptor()
        rpd.colorAttachments[0].texture = drawable?.texture
        rpd.colorAttachments[0].loadAction = .clear
        // 绘制的背景颜色
        rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.8, 0.5, 1.0)

        commandBuffer = commandQueue?.makeCommandBuffer()

        let re: MTLRenderCommandEncoder? = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
        re?.setRenderPipelineState(pipelineState!)
        re?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        re?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

        re?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        re?.endEncoding()
        // 保证新纹理会在绘制完成后立即出现
        commandBuffer?.present(drawable!)
        commandBuffer?.commit()
    }
    
}
