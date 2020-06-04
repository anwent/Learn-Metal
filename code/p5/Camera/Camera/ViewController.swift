//
//  ViewController.swift
//  Camera
//
//  Created by zh on 2020/6/4.
//  Copyright © 2020 zh. All rights reserved.
//

import UIKit
import AVFoundation
import MetalKit
import Foundation

class ViewController: UIViewController {

    var session: AVCaptureSession?
    var textureCache: CVMetalTextureCache?
    var cmdQueue: MTLCommandQueue?
    
    var cameraTexture: MTLTexture?
    var cmdBuffer: MTLCommandBuffer?
    
    var renderPiplineState: MTLRenderPipelineState?
    
    fileprivate let semaphore = DispatchSemaphore(value: 1)
    
    private lazy var mtkView: MTKView = {
        let mtkView = MTKView(frame: view.bounds, device: MTLCreateSystemDefaultDevice())
        mtkView.delegate = self
        mtkView.framebufferOnly = false
        return mtkView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        metal()
        captureSession()
        createRenderPipline()
     
        
        
    }

}

extension ViewController {
    
    private func metal() {
        view.addSubview(mtkView)
        cmdQueue = mtkView.device?.makeCommandQueue()
        guard let device = mtkView.device else { return }
        CVMetalTextureCacheCreate(kCFAllocatorDefault,
                                  nil,
                                  device,
                                  nil,
                                  &textureCache)
    }
    
    private func createRenderPipline() {
        let plDes = MTLRenderPipelineDescriptor()
        plDes.sampleCount = 1
        plDes.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        plDes.depthAttachmentPixelFormat = .invalid
        let lib = mtkView.device?.makeDefaultLibrary()
        plDes.vertexFunction = lib?.makeFunction(name: "vertex_shader")
        plDes.fragmentFunction = lib?.makeFunction(name: "fragment_shader")
        renderPiplineState = try? mtkView.device?.makeRenderPipelineState(descriptor: plDes)
    }
    
    private func render() {
        guard
            let currentRenderPassDescriptor = mtkView.currentRenderPassDescriptor,
            let rpl = renderPiplineState,
            let texture = cameraTexture,
            let drawable = mtkView.currentDrawable,
        let commandBuffer = cmdQueue?.makeCommandBuffer()
            else { return }
        
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor)
        encoder?.setRenderPipelineState(rpl)
        encoder?.setFragmentTexture(texture, index: 0)
        /*
         
         .triangleStrip
         
         For every three adjacent vertices, rasterize a triangle.
         
         eg:
         
                C
         
         A              D
            
                B
         
         [A, B, C, D] => △ABC   △BCD  ✅
         [A, B, D, C] => △ABD   △BDC  ❌
         
         
         
         */
        encoder?.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4, instanceCount: 1)
        encoder?.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func captureSession() {
        session = AVCaptureSession()
        session?.sessionPreset = .hd1920x1080
        let queue = DispatchQueue(label: "my_camera_queue")
        guard let inputCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let deviceInput = try? AVCaptureDeviceInput(device: inputCamera) else { return }
        session?.addInput(deviceInput)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.alwaysDiscardsLateVideoFrames = false
        deviceOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA]
        deviceOutput.setSampleBufferDelegate(self, queue: queue)
        session?.addOutput(deviceOutput)
        let connection = deviceOutput.connection(with: .video)
        connection?.videoOrientation = .portrait
        session?.startRunning()
    }
}


extension ViewController: MTKViewDelegate {
    
    func draw(in view: MTKView) {
        render()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard
            let pixelBuffer: CVImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let tCache = textureCache
            else {
                semaphore.signal()
                return
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        var outTexture: CVMetalTexture?
        let status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                               tCache,
                                                               pixelBuffer,
                                                               nil,
                                                               .rgba8Unorm,
                                                               width,
                                                               height,
                                                               0,
                                                               &outTexture)
        
        if status == kCVReturnSuccess {
            mtkView.drawableSize = CGSize(width: width, height: height)
            cameraTexture = CVMetalTextureGetTexture(outTexture!)
        }
        
    }
    
}
