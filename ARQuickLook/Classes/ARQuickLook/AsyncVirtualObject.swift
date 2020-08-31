/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Methods on the main view controller for conforming to the ARCoachingOverlayViewDelegate protocol
*/

import UIKit
import ARKit
import GLTFSceneKit

/// - Tag: Code Setup
@available(iOS 13.0, *)
class AsyncVirtualObject: VirtualObject {
    public var maxSizeInMeters: Float = 1
    public var zoom: Float = 1
    public let item: ARItem

    public init?(_ item: ARItem) {
        self.item = item
        super.init(url: item.path)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func load(onLoaded: ((_ scene: SCNScene?) -> Void)?) {
        let uri = referenceURL
        if uri.scheme?.lowercased().starts(with: "http") ?? false {
            preload() { success in
                self.loadLocally(onLoaded: onLoaded)
            }
        }else{
            DispatchQueue.global(qos: .userInitiated).async {
                self.loadLocally(onLoaded: onLoaded)
            }
        }
    }

    public func loadLocally(onLoaded: ((_ scene: SCNScene?) -> Void)?) {
        let uri = referenceURL
        var mode = 0
        if (item.format == "GLB" || item.format == "GLTF") {
            mode = 1
        }
        do {
            var node: SCNScene
            switch mode {
            case 1:
                let data: Data = try Data(contentsOf: uri)
                let sceneSource = GLTFSceneSource(data: data)
                node = try sceneSource.scene()
                break
            default:
                node = try SCNScene(url: uri)
                break
            }
            self.initNode(node)
            onLoaded?(node)
        } catch {
            print("loadFile: \(error.localizedDescription)")
            onLoaded?(nil)
        }
    }

    func initNode(_ scene: SCNScene) {
        let node = SCNNode()
        for n in scene.rootNode.childNodes {
            n.scale = SCNVector3(zoom, zoom, zoom)
            node.addChildNode(n)
        }
        let b = node.boundingBox
        let m = max(max(b.max.x - b.min.x, b.max.y - b.min.y), b.max.z - b.min.z)
        if m > maxSizeInMeters {
            let scale = maxSizeInMeters / m
            node.scale = SCNVector3(scale, scale, scale)
        }
        let containerNode = SCNNode()
        containerNode.addChildNode(node)
        addChildNode(containerNode)
    }

    private func printNode(_ node: SCNNode) {
        if let camera = node.camera {
            print(node, camera)
        }
        for n in node.childNodes {
            printNode(n)
        }

    }

    override func unload() {
        childNodes.first?.removeFromParentNode()
    }

    public func preload(onPrepared: ((_ success: Bool) -> Void)? = nil) {
        let uri = referenceURL
        if !(uri.scheme?.lowercased().starts(with: "http") ?? false) { return }

        let req = URLRequest(url: uri)

        let task = URLSession.shared.dataTask(with: req) {(data, response, error) in
            guard let data = data else { return }
            //let ret = self.loadData(data, format: fmt)
            do {
                let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(uri.lastPathComponent).\(self.item.format.lowercased())")
                try data.write(to: path)
                self.referenceURL = path
                if (onPrepared != nil) {
                    DispatchQueue.main.async {
                        onPrepared?(true)
                    }
                }
            } catch {
                print("loadUrl: \(error.localizedDescription)")
                if (onPrepared != nil) {
                    DispatchQueue.main.async {
                        onPrepared?(false)
                    }
                }
            }
        }
        task.resume()
    }

}
