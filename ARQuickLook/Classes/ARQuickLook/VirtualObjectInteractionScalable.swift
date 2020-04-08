/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages user interaction with virtual objects to enable one-finger tap, one- and two-finger pan,
 and two-finger rotation gesture recognizers to let the user position and orient virtual objects.
 
 Note: this sample app doesn't allow object scaling because quite often, scaling doesn't make sense
 for certain virtual items. For example, a virtual television can be scaled within some small believable
 range, but a virtual guitar should always remain the same size.
*/

import UIKit
import ARKit

/// - Tag: VirtualObjectInteraction With Scale Gesture
@available(iOS 13.0, *)
class VirtualObjectInteractionScalable: VirtualObjectInteraction {

    override init(sceneView: VirtualObjectARView, viewController: ViewController) {
        super.init(sceneView: sceneView, viewController: viewController)
                let scaleGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        scaleGesture.delegate = self
        sceneView.addGestureRecognizer(scaleGesture)
    }

    func disableGestures(_ settings: Dictionary<String, String>) {
        guard let gestures = sceneView.gestureRecognizers else {
            return
        }
        for gesture in gestures {
            if (settings["scale"] == "false" && gesture is UIPinchGestureRecognizer ||
                settings["rotate"] == "false" && gesture is UIRotationGestureRecognizer ||
                settings["drag"] == "false"  && gesture is UIPanGestureRecognizer ||
                settings["tap"] == "false"  && gesture is UITapGestureRecognizer) {
                sceneView.removeGestureRecognizer(gesture)
            }
        }
    }

    @objc
    func didPinch(_ gesture: UIPinchGestureRecognizer) {
        guard gesture.state == .changed,
            let obj = trackedObject?.childNodes.first
            else { return }

        let n = Float(gesture.scale)
        obj.scale = SCNVector3(obj.scale.x * n, obj.scale.y * n, obj.scale.z * n)

        gesture.scale = 1
    }

    override func didRotate(_ gesture: UIRotationGestureRecognizer) {
        super.didRotate(gesture)
    }

    override func didPan(_ gesture: ThresholdPanGesture) {
        super.didPan(gesture)
    }

    override func setDown(_ object: VirtualObject, basedOn screenPos: CGPoint) {
        super.setDown(object, basedOn: screenPos)
    }

    override func gestureRecognizer(_ l: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith r: UIGestureRecognizer) -> Bool {
        return !(l is UIPinchGestureRecognizer && r is UIRotationGestureRecognizer || r is UIPinchGestureRecognizer && l is UIRotationGestureRecognizer)
    }


}
