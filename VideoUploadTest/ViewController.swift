//
//  ViewController.swift
//  VideoUploadTest
//
//  Created by Charanbir sandhu on 14/07/20.
//  Copyright © 2020 Charan Sandhu. All rights reserved.
//

import UIKit
import AVKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func btn() {
        guard let url = Bundle.main.url(forResource: "a", withExtension: "MOV") else { return }
//        guard let data = try? Data(contentsOf: url)  else { return }
//        uploadVideo(videoData: data)
        //540, 960
        let model = VideoModel()
        model.editedVideoUrl = url
        model.rotation = .zero
        model.flipVerticalVideo = true
        
        let timestamp = String(Date().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")
        let videoPath = NSTemporaryDirectory() + timestamp + "movie.mp4"
        let videoURL = URL(fileURLWithPath: videoPath)
        
        Composer.compose(videoURL: url, outputURL: videoURL, completion: { (url) in
            if let url = url {
                print(url)
            }
        }, updateTime: { updation in
            print(updation)
        })
        
//        VideoTrim.compose(startTime: 0, endTimeDuration: 2, model: model, outputURL: videoURL, completion: { (url) in
//            if let url = url {
//                print(url)
//            }
//        }, updateTime: { updation in
//            print(updation)
//        })
        
    }

    
}



struct VideoTrim {
    static func compose(startTime: Double, endTimeDuration: Double, model: VideoModel, outputURL: URL, completion: @escaping (URL?) -> Void, updateTime: @escaping (Float)->Void) {
        guard let url = model.editedVideoUrl else {fatalError("crash compose")}
        let asset = AVURLAsset(url: url)
        
        guard let clipVideoTrack = asset.tracks(withMediaType: .video).first else {
            fatalError("crash compose")
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: clipVideoTrack.naturalSize.width,
                                             height: clipVideoTrack.naturalSize.height)
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        let startCmTime = CMTime(seconds: startTime, preferredTimescale: 1000)
        let endCmTime = CMTime(seconds: endTimeDuration, preferredTimescale: 1000)
        let timeRange = CMTimeRangeMake(start: startCmTime, duration: endCmTime)
        instruction.timeRange = timeRange
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        var transform = asset.preferredTransform
        var videoSize = CGSize(width: clipVideoTrack.naturalSize.width, height: clipVideoTrack.naturalSize.height)
        
        switch model.rotation {
        case .zero:
            if model.flipHorizantalVideo, model.flipVerticalVideo {
                transform = transform.translatedBy(x: clipVideoTrack.naturalSize.width, y: clipVideoTrack.naturalSize.height)
                transform = transform.scaledBy(x: -1, y: -1)
            } else if model.flipHorizantalVideo {
                transform = transform.translatedBy(x: clipVideoTrack.naturalSize.width, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            } else if model.flipVerticalVideo {
                transform = transform.translatedBy(x: 0, y: clipVideoTrack.naturalSize.height)
                transform = transform.scaledBy(x: 1, y: -1)
            }
        case .ninty:
            videoSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
            transform = transform.rotated(by: (90 * CGFloat.pi) / 180)
            if model.flipHorizantalVideo, model.flipVerticalVideo {
                transform = transform.translatedBy(x: clipVideoTrack.naturalSize.width, y: 0)
                transform = transform.scaledBy(x: -1, y: -1)
            } else if model.flipHorizantalVideo {
                transform = transform.translatedBy(x: 0, y: 0)
                transform = transform.scaledBy(x: 1, y: -1)
            } else if model.flipVerticalVideo {
                transform = transform.translatedBy(x: clipVideoTrack.naturalSize.width, y: -clipVideoTrack.naturalSize.height)
                transform = transform.scaledBy(x: -1, y: 1)
            }else {
                transform = transform.translatedBy(x: 0, y: -clipVideoTrack.naturalSize.height)
            }
        case .oneEighty:
            transform = transform.rotated(by: (180 * CGFloat.pi) / 180)
            if model.flipHorizantalVideo, model.flipVerticalVideo {
                transform = transform.translatedBy(x: 0, y: 0)
                transform = transform.scaledBy(x: -1, y: -1)
            } else if model.flipHorizantalVideo {
                transform = transform.translatedBy(x: 0, y: -clipVideoTrack.naturalSize.height)
                transform = transform.scaledBy(x: -1, y: 1)
            } else if model.flipVerticalVideo {
                transform = transform.translatedBy(x: -clipVideoTrack.naturalSize.width, y: 0)
                transform = transform.scaledBy(x: 1, y: -1)
            } else {
                transform = transform.translatedBy(x: -clipVideoTrack.naturalSize.width, y: -clipVideoTrack.naturalSize.height)
            }
        case .twoSeventy:
            videoSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.width)
            transform = transform.rotated(by: (270 * CGFloat.pi) / 180)
            if model.flipHorizantalVideo, model.flipVerticalVideo {
                transform = transform.translatedBy(x: 0, y: clipVideoTrack.naturalSize.height)
                transform = transform.scaledBy(x: -1, y: -1)
            } else if model.flipHorizantalVideo {
                transform = transform.translatedBy(x: -clipVideoTrack.naturalSize.width, y: clipVideoTrack.naturalSize.height)
                transform = transform.scaledBy(x: 1, y: -1)
            } else if model.flipVerticalVideo {
                transform = transform.translatedBy(x: 0, y: 0)
                transform = transform.scaledBy(x: -1, y: 1)
            }else {
                transform = transform.translatedBy(x: -clipVideoTrack.naturalSize.width, y: 0)
            }
        }
        
        transformer.setTransform(transform, at: CMTime.zero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            fatalError("crash compose")
        }
        videoComposition.renderSize = videoSize
        exporter.timeRange = timeRange
        exporter.videoComposition = videoComposition
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        var isOn = true
        DispatchQueue.global().async {
            while isOn {
                updateTime(exporter.progress)
                usleep(10000)
            }
        }
        exporter.exportAsynchronously {
            switch exporter.status {
            case .completed:
                completion(exporter.outputURL)
            default:
                debugPrint(exporter.error)
                fatalError("crash compose")
            }
            isOn = false
        }
    }
}

struct Composer {
    static func compose(videoURL: URL, outputURL: URL, completion: @escaping (URL?) -> Void, updateTime: @escaping (Float)->Void) {
        let asset = AVURLAsset(url: videoURL)
        
        guard let clipVideoTrack = asset.tracks(withMediaType: .video).first else {
            fatalError("crash compose")
        }
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: clipVideoTrack.naturalSize.width,
                                             height: clipVideoTrack.naturalSize.height)
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        
        let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        let t1 = CGAffineTransform(translationX: 0, y: 0)
        let t2 = t1.rotated(by: (20 * CGFloat.pi) / 180)
        
        
        transformer.setTransform(t2, at: CMTime.zero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality) else {
            fatalError("crash compose")
        }
        exporter.videoComposition = videoComposition
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        var isOn = true
        DispatchQueue.global().async {
            while isOn {
                updateTime(exporter.progress)
                usleep(10000)
            }
        }
        exporter.exportAsynchronously {
            switch exporter.status {
            case .completed:
                completion(exporter.outputURL)
            default:
                debugPrint(exporter.error)
                fatalError("crash compose")
            }
            isOn = false
        }
    }
}

class VideoModel  {
    var fullVidelUrl: URL?
    var editedVideoUrl: URL?
    var startTime: Double = 0
    var endTime: Double = 0
    var duration: Double = 0
    var rotation: RotationVideo = .zero
    var image: CGImage?
    var imageSlider: CGImage?
    var flipHorizantalVideo = false
    var flipVerticalVideo = false
    var normalFilters: [CIFilter] = []
    var arFilters: [CIFilter] = []
    var cropRect = CGRect.zero
}

enum RotationVideo: Double {
    case zero = 0
    case ninty = 90
    case oneEighty = 180
    case twoSeventy = 270
}

extension ViewController: URLSessionDataDelegate {
    
    func uploadVideo(videoData: Data) {
            let fullPath = "http://206.189.154.77/api/media-upload/"
            guard let url = URL(string: fullPath) else {
                return
            }
            //
            var request = URLRequest(url: url)
            request.httpMethod = "post"
            request.setValue("video.mp4", forHTTPHeaderField: "temp_media_path")
            let configuration = URLSessionConfiguration.default
    //        let configuration = URLSessionConfiguration.background(withIdentifier: "it.example.upload")
    //        configuration.isDiscretionary = false
    //        configuration.networkServiceType = .video
            let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
            let task = session.uploadTask(with: request, from: videoData) { (data, response, error) in
                if (error==nil) {
                    guard let response = data else {
                        print("Data is nil")
                        return
                    }
                    do {
                        let js = try JSONSerialization.jsonObject(with: response, options: [])
                        print(js)
                    } catch {
                        print(error)
                    }
                } else {
                    print(error)
                }
            }
            task.resume()
        }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data){
        guard let js = try? JSONSerialization.jsonObject(with: data, options: []) else{return}
        print(js)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64){
        let persent = (Double(totalBytesSent)/Double(totalBytesExpectedToSend))
        print(persent)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(error)
    }
}
