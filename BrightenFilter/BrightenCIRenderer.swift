//
//  File.swift
//  AVCamFilter
//
//  Created by 孟祥宇 on 2022/12/29.
//  Copyright © 2022 Apple. All rights reserved.
//  Abstract:
//  The brighten filter renderer, implemented with Core Image.
//

import CoreMedia
import CoreVideo
import CoreImage
import CoreML


class BrightenCIRenderer: FilterRenderer {
    
    var description: String = "Brighten (Core Image)"
    
    var isPrepared = false
    
//    var model3: model60M!
    private var model3: mbllen_onlyTransformer!
    private var ciContext: CIContext?
    private var rosyFilter: CIFilter?
    private var outputColorSpace: CGColorSpace?
    private var outputPixelBufferPool: CVPixelBufferPool?
    private(set) var outputFormatDescription: CMFormatDescription?
    private(set) var inputFormatDescription: CMFormatDescription?
    
    /// - Tag: FilterCoreImageRosy
    func prepare(with formatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int) {
        reset()
        
        (outputPixelBufferPool,outputColorSpace,
         outputFormatDescription) = allocateOutputBufferPool(with: formatDescription,
                                                             outputRetainedBufferCountHint: outputRetainedBufferCountHint)
        if outputPixelBufferPool == nil {
            return
        }
        inputFormatDescription = formatDescription
        ciContext = CIContext()
        rosyFilter = CIFilter(name: "CIColorMatrix")
        rosyFilter!.setValue(CIVector(x: 0, y: 0, z: 0, w: 0), forKey: "inputGVector")
        isPrepared = true
        do{
            print("get transformer")
            model3 = try mbllen_onlyTransformer()
            
        }catch{
            print("err")
        }
    }
    
    func reset() {
        outputColorSpace = nil
        outputPixelBufferPool = nil
        outputFormatDescription = nil
        inputFormatDescription = nil
        isPrepared = false
    }
    
    func render(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        
        
        //查看输入pixelbuffer尺寸
        let originWidth = CVPixelBufferGetWidth(pixelBuffer);
        let originHeight = CVPixelBufferGetHeight(pixelBuffer);
//        print(originWidth,originHeight)

        // 调用resizepixelBuffer方法
        let resizedPixelBuffer = resizePixelBuffer(pixelBuffer, width: 1104, height: 828)
//        print(CVPixelBufferGetWidth(resizedPixelBuffer!))
        
        
        // 调用模型
        guard let prediction = try? model3.prediction(input_image: resizedPixelBuffer!) else {return nil;}
        let predictionPixelBuffer = prediction.output_image

        
        // 调用resizepixelBuffer方法
        let resizedPixelBuffer2 = resizePixelBuffer(predictionPixelBuffer, width:originWidth , height:originHeight )

        
        
        // 输出pixelBuffer
        return resizedPixelBuffer2
        
        
        
        
//        原来的，使用滤镜的代码
//        guard let rosyFilter = rosyFilter,
//            let ciContext = ciContext,
//            isPrepared else {
//                assertionFailure("Invalid state: Not prepared")
//                return nil
//        }
//
//        let sourceImage = CIImage(cvImageBuffer: pixelBuffer)
//        rosyFilter.setValue(sourceImage, forKey: kCIInputImageKey)
//
//        guard let filteredImage = rosyFilter.value(forKey: kCIOutputImageKey) as? CIImage else {
//            print("CIFilter failed to render image")
//            return nil
//        }
//
//        var pbuf: CVPixelBuffer?
//        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, outputPixelBufferPool!, &pbuf)
//        guard let outputPixelBuffer = pbuf else {
//            print("Allocation failure")
//            return nil
//        }
//
//        // Render the filtered image out to a pixel buffer (no locking needed, as CIContext's render method will do that)
//        ciContext.render(filteredImage, to: outputPixelBuffer, bounds: filteredImage.extent, colorSpace: outputColorSpace)
//        return pixelBuffer

        
        
        
    }
}
