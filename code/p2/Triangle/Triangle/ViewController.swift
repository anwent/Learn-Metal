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
        
        let vertexData: [Vertex] = [Vertex(position: [-0.5, 0.5, 0.0, 1.0], color: [1, 0, 0, 1]),
                                    Vertex(position: [0.0, -0.5, 0.0, 1.0], color: [0, 1, 0, 1]),
                                    Vertex(position: [-1.0, -0.5, 0.0, 1.0], color: [0, 0, 1, 1])]
        vertexBuffer = device?.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Vertex>.size, options: [])
    }
    
    private func p6_createRenderPipeline() {
        
        let defaultLibrary = device?.makeDefaultLibrary()
        let fragmentFunc = defaultLibrary?.makeFunction(name: "fragment_shader")
        let vertexFunc = defaultLibrary?.makeFunction(name: "vertex_shader")
        
        
        // 这里设置你的render pipeline。它包含你想要使用的shaders、颜色附件（color attachment）的像素格式(pixel format)。（例如：你渲染到的输入缓冲区，也就是CAMetalLayer
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
        // - createRenderPassDescriptor
        
        // metal layer上调用nextDrawable() ，它会返回你需要绘制到屏幕上的纹理(texture)
        let drawable = metalLayer.nextDrawable()
        // 创建一个Render Pass Descriptor，配置什么纹理会被渲染到、clear color，以及其他的配置
        let rpd = MTLRenderPassDescriptor()
        rpd.colorAttachments[0].texture = drawable?.texture
        rpd.colorAttachments[0].loadAction = .clear
        // 绘制的背景颜色
        rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.8, 0.5, 1.0)
        
        // - createCommandBuffer
        commandBuffer = commandQueue?.makeCommandBuffer()
        
        // 创建一个渲染命令编码器(Render Command Encoder)
        // 创建一个command encoder，并指定你之前创建的pipeline和顶点
        let re: MTLRenderCommandEncoder? = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
        re?.setRenderPipelineState(pipelineState!)
        re?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        /*
         绘制图形
         - parameter type:          画三角形
         - parameter vertexStart:   从vertex buffer 下标为0的顶点开始
         - parameter vertexCount:   顶点数
         - parameter instanceCount: 总共有1个三角形
         */
        re?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        re?.endEncoding()
        // 保证新纹理会在绘制完成后立即出现
        commandBuffer?.present(drawable!)
        commandBuffer?.commit()
    }
    
}
