//
//  ViewController.swift
//  Texture
//
//  Created by zh on 2020/6/3.
//  Copyright © 2020 zh. All rights reserved.
//

import UIKit
import MetalKit
import Metal
import simd

class ViewController: UIViewController {
    
    private var piplineState: MTLRenderPipelineState?
    
    private var commandQueue: MTLCommandQueue?
    
    private var texture: MTLTexture?
    
    private var vBuffer: MTLBuffer?
    
    private var viewportSize: vector_uint2?
    
    private lazy var mtkView: MTKView = {
        let mtkView = MTKView(frame: view.bounds, device: MTLCreateSystemDefaultDevice())
//        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.delegate = self
        return mtkView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mtkView)
        loadTexture()
        
        self.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)
        
    }

}


extension ViewController {
    
    
    
    private func loadTexture() {
//
//        guard let file = Bundle.main.url(forResource: "ttt", withExtension: "tga") else { return }
        
//        texture = loadTextureUsingAAPLImage(file)
        loadTextureUsingAAPLImage()
        
        
        
        let quad_vertices: [Vertex] = [Vertex(position: vector_float2(x: 200.0,  y: -200.0), textureCoordinate: vector_float2(x: 1.0, y: 1.0)),
                                       Vertex(position: vector_float2(x: -200.0, y: -200.0), textureCoordinate: vector_float2(x: 0.0, y: 1.0)),
                                       Vertex(position: vector_float2(x: -200.0, y: 200.0),  textureCoordinate: vector_float2(x: 0.0, y: 0.0)),
                                       
                                       Vertex(position: vector_float2(x: 200.0,  y: -200.0), textureCoordinate: vector_float2(x: 1.0, y: 1.0)),
                                       Vertex(position: vector_float2(x: -200.0, y: 200.0),  textureCoordinate: vector_float2(x: 0.0, y: 0.0)),
                                       Vertex(position: vector_float2(x: 200.0, y: 200.0),   textureCoordinate: vector_float2(x: 1.0, y: 0.0))]
        
        vBuffer = mtkView.device?.makeBuffer(bytes: quad_vertices,
                                             length: quad_vertices.count * MemoryLayout<Vertex>.size,
                                             options: .storageModeShared)
        
        
        let lib = mtkView.device?.makeDefaultLibrary()
        let vertexFunc = lib?.makeFunction(name: "vertex_shader")
        let fragmentFunc = lib?.makeFunction(name: "fragment_shader")
        
        let rpd = MTLRenderPipelineDescriptor()
        rpd.vertexFunction = vertexFunc
        rpd.fragmentFunction = fragmentFunc
        rpd.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        piplineState = try? mtkView.device?.makeRenderPipelineState(descriptor: rpd)
        
        commandQueue = mtkView.device?.makeCommandQueue()

    }
    
    
    func loadTextureUsingAAPLImage() {
        
        
        let img = UIImage(named: "pic")
        let textureDes = MTLTextureDescriptor()
        textureDes.pixelFormat = .rgba8Unorm
        textureDes.width = Int(img?.size.width ?? 0)
        textureDes.height = Int(img?.size.height ?? 0)
        self.texture = mtkView.device?.makeTexture(descriptor: textureDes)
        
        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
                               size: MTLSize(width: Int(img?.size.width ?? 0), height: Int(img?.size.height ?? 0), depth: 1))
        
//        let byte = AAPLImage.load(img!)
        if let b = AAPLImage.load(img!) {
            
            
            self.texture?.replace(region: region,
                                  mipmapLevel: 0,
                                  withBytes: b,
                                  bytesPerRow: 4 * Int(img?.size.width ?? 0))
            free(b)
            
            
            
        }
    }
        
    
}

extension ViewController: MTKViewDelegate {
    
    func draw(in view: MTKView) {
        
        let cmdBuffer = commandQueue?.makeCommandBuffer()
        
        guard
            let rpd = mtkView.currentRenderPassDescriptor
//            let pls = piplineState,
//            let vb = vBuffer,
//            let db = mtkView.currentDrawable
            else {
                return
        }
        let renderEncoder = cmdBuffer?.makeRenderCommandEncoder(descriptor: rpd)
        

        renderEncoder?.setViewport(MTLViewport(originX: 0,
                                               originY: 0,
                                               width: Double(viewportSize?.x ?? 0),
                                               height: Double(viewportSize?.y ?? 0),
                                               znear: -1.0,
                                               zfar: 1.0))
        
        renderEncoder?.setRenderPipelineState(piplineState!)
        
        renderEncoder?.setVertexBuffer(vBuffer!,
                                       offset: 0,
                                       index: 0)
        
        renderEncoder?.setVertexBytes(&viewportSize!,
                                      length: MemoryLayout<vector_uint2>.size,
                                      index: 1)
        
        renderEncoder?.setFragmentTexture(texture,
                                          index: 0)
        
        renderEncoder?.drawPrimitives(type: .triangle,
                                      vertexStart: 0,
                                      vertexCount: 6)
        
        renderEncoder?.endEncoding()
        cmdBuffer?.present(mtkView.currentDrawable!)
        
        cmdBuffer?.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize = vector_uint2(x: UInt32(size.width), y: UInt32(size.height))
    }
    
}
