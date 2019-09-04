//
//  ViewController.swift
//  Metal-01
//
//  Created by zh on 2019/9/4.
//  Copyright © 2019 zh. All rights reserved.
//

import UIKit
import Metal
import MetalKit
import QuartzCore

fileprivate let vertexData: [Float] = [
    0.0, 1.0, 0.0,
    -1.0, -1.0, 0.0,
    1.0, -1.0, 0.0
]

class ViewController: UIViewController {
    
    // gpu
    private var device: MTLDevice! = nil
    
    private var metalLayer: CAMetalLayer! = nil
    
    private var vertexBuffer: MTLBuffer! = nil
    
    private var pipelineState: MTLRenderPipelineState! = nil
    
    private var cmdQueue: MTLCommandQueue! = nil
    
    private var timer: CADisplayLink! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始化device
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        
        let dataSize = MemoryLayout<Float>.size * vertexData.count
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: MTLResourceOptions(rawValue: 0))
        
        
        let defaultLibrary = device.makeDefaultLibrary()
        let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
        
        let des = MTLRenderPipelineDescriptor()
        des.vertexFunction = vertexProgram
        des.fragmentFunction = fragmentProgram
        des.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: des)
        
        cmdQueue = device.makeCommandQueue()
        
        render()
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        timer.add(to: .main, forMode: .default)
        
    }
    
    @objc private func gameloop() {
        autoreleasepool {
            self.render()
        }
    }
    
    func render() {
        let random_r = Double(arc4random() % 255) / 255
        let random_g = Double(arc4random() % 255) / 255
        let random_b = Double(arc4random() % 255) / 255
        
        guard let drawable = metalLayer.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(random_r, random_g, random_b, 1)
        
        let cmdBuffer = cmdQueue.makeCommandBuffer()
        let renderEncoder = cmdBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder?.setRenderPipelineState(pipelineState)
        renderEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        renderEncoder?.endEncoding()
        
        cmdBuffer?.present(drawable)
        cmdBuffer?.commit()
    }
    
}
