/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit


struct ARItem {
    let url: String
    let path: URL
    let format: String
    let title: String?
    let thumbnail: String?

    init(url: String, thumbnail: String? = nil, title: String? = nil) {
        guard let path = URL(string: url) else { fatalError("Invalid url") }
        self.url = url
        self.path = path
        self.format = path.pathExtension.uppercased()
        self.thumbnail = thumbnail
        self.title = title
    }
}


@available(iOS 13.0, *)
@objcMembers
public class ARQuickLookController: NSObject {
    static let supportedScheme = ["http", "file"]
    static let supportedFormat = ["GLB", "GLTF", "OBJ", "DAE", "ABC", "PLY", "STL", "USD", "USDZ", "USDA", "USDC", "SCN"]

    public var translations: Dictionary<String, String>? = nil
    public var headers: Dictionary<String, String>? = nil
    var models: Array<ARItem> = []
    var settings: Dictionary<String, String> = [
        "max": "10",
        "zoom": "1",
        "scale": "false",
        "rotate": "true",
        "drag": "true",
        "tap": "true",
        "lighting": "true",
    ]
    private var loading = false

    public convenience init(
        models: Array<Dictionary<String, String>>,
        settings: Dictionary<String, Any>
    ) {
        self.init()

//        if let models = settings["models"] as? Array<Dictionary<String, String>> { }
        for model in models {
            let item = ARItem(url: model["m"]!, thumbnail: model["tn"], title: model["t"])
            self.models.append(item)
//            if self.models.count > 3 { break }
        }

        if let gestures = settings["gestures"] as? Dictionary<String, Bool> {
            for gesture in ["scale", "rotate", "drag", "tap"] {
                if gestures[gesture] != nil {
                    self.settings[gesture] = gestures[gesture]! ? "true" : "false"
                }
                self.settings[gesture] = "false"
            }
        }
        if let m = settings["max"], !(m is NSNull) {
            self.settings["max"] = "\(m)"
        }

        if let m = settings["scale"], !(m is NSNull) {
            self.settings["zoom"] = "\(m)"
        }

        if let m = settings["lighting"] as? Bool {
            self.settings["lighting"] = m ? "true" : "false"
        }
    }

//    public func loadUrl(onPrepared: ((_ success: Bool) -> Void)? = nil) {
//        if (loading) {
//            //onPrepared?(path != nil)
//            return
//        }
//        guard let url = settings["url"] else {return}
//        guard let format = settings["format"] else {return}
//        let uri = URL(string: url)!
//
//        var req = URLRequest(url: uri)
//        req.allHTTPHeaderFields = headers
//        loading = true
//
//        let task = URLSession.shared.dataTask(with: req) {(data, response, error) in
//            guard let data = data else { return }
//            //let ret = self.loadData(data, format: fmt)
//            do {
//                let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(uri.lastPathComponent).\(format.lowercased())")
//                try data.write(to: path)
//                self.path = path
//                self.ensureFormat()
//                self.loading = false
//                if (onPrepared != nil) {
//                    DispatchQueue.main.async {
//                        onPrepared?(true)
//                    }
//                }
//            } catch {
//                self.loading = false
//                print("loadUrl: \(error.localizedDescription)")
//                if (onPrepared != nil) {
//                    DispatchQueue.main.async {
//                        onPrepared?(false)
//                    }
//                }
//            }
//        }
//        task.resume()
//    }

    public func launchAR(_ presenter: UIViewController?, completion: (() -> Void)? = nil) {
//        loadUrl()
        let ar = ViewController()
        ar.controller = self
        ar.modalPresentationStyle = .fullScreen
        var p = presenter
        if (p == nil) {
            p = UIApplication.shared.delegate?.window??.rootViewController
        }
        p?.present(ar, animated: true, completion: completion)
    }
}
