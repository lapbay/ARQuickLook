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
    var format: String
    public var maxSizeInMeters: Float = 1
    public var zoom: Float = 1

    public init?(url referenceURL: URL, format: String) {
        self.format = format
        super.init(url: referenceURL)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func load(onLoaded: ((_ scene: SCNScene?) -> Void)?) {
        let uri = referenceURL
        var mode = 0
        if (format == "GLB" || format == "GLTF") {
            mode = 1
        }
        DispatchQueue.global(qos: .userInitiated).async {
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
    }

    func initNode(_ scene: SCNScene) {
        let node = SCNNode()
        for n in scene.rootNode.childNodes {
            node.addChildNode(n)
        }
        node.scale = SCNVector3(zoom, zoom, zoom)
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
}
