//
//  Ex+MTLDevice.swift
//  Texture
//
//  Created by zh on 2020/6/4.
//  Copyright © 2020 zh. All rights reserved.
//

import MetalKit

//extension MTLDevice {
//    
//    func loadTextureUsingAAPLImage(_ url: URL) -> MTLTexture? {
//        guard let image = AAPLImage(tgaFileAtLocation: url) else {
//            return nil
//        }
//        let textureDes = MTLTextureDescriptor()
//        textureDes.pixelFormat = .bgra8Unorm
//        textureDes.width = Int(image.width)
//        textureDes.height = Int(image.height)
//        let texture = makeTexture(descriptor: textureDes)
//        
//        let region = MTLRegion(origin: MTLOrigin(x: 0, y: 0, z: 0),
//                               size: MTLSize(width: textureDes.width, height: textureDes.height, depth: 1))
//        let preRowBytes = textureDes.width * MemoryLayout<Int>.size
//        texture?.replace(region: region,
//                         mipmapLevel: 0,
//                         withBytes: (image.data as NSData).bytes,
//                         bytesPerRow: preRowBytes)
//        
//        print(region)
////        0x0000000162000000
//        return texture
//    }
//    
//}
