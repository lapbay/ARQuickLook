/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import UIKit

@available(iOS 13.0, *)
@objcMembers
public class ARQuickLookController: NSObject {
    static let supportedScheme = ["http", "file"]
    static let supportedFormat = ["GLB", "GLTF", "OBJ", "DAE", "ABC", "PLY", "STL", "USD", "USDZ", "USDA", "USDC", "SCN"]

    public var translations: Dictionary<String, String>? = nil
    public var headers: Dictionary<String, String>? = nil
    var settings: Dictionary<String, String> = [
        "url": "",
        "format": "",
        "max": "10",
        "zoom": "1",
        "scale": "false",
        "rotate": "true",
        "drag": "true",
        "tap": "true"
    ]
    var path: URL? = nil
    private var loading = false

    public convenience init(
        settings: Dictionary<String, Any>,
        onPrepared: ((_ success: Bool) -> Void)? = nil
    ) {
        self.init()

        if let format = settings["format"] as? String {
            assert(ARQuickLookController.supportedFormat.contains(format.uppercased()), "format not supported")
            self.settings["format"] = format.uppercased()
        }

        if let url = settings["url"] as? String {
            let ul = url.lowercased()
            assert(ul.starts(with: "http") || ul.starts(with: "file"), "url must starts with http or file")
            self.settings["url"] = url
            guard let uri = URL(string: url) else {
                fatalError("invalid url")
            }
            if uri.isFileURL {
                path = uri
                ensureFormat()
                onPrepared?(true)
            }else if (onPrepared != nil){
                loadUrl(onPrepared: onPrepared)
            }
        }

        if let gestures = settings["gestures"] as? Dictionary<String, Bool> {
            for gesture in ["scale", "rotate", "drag", "tap"] {
                if gestures[gesture] != nil {
                    self.settings[gesture] = gestures[gesture]! ? "true" : "false"
                }
            }
        }

        if let m = settings["max"], !(m is NSNull) {
            self.settings["max"] = "\(m)"
        }

        if let m = settings["scale"], !(m is NSNull) {
            self.settings["zoom"] = "\(m)"
        }
    }

    private func ensureFormat() {
        if let _ = settings["format"] {
            return
        }
        let format = path!.pathExtension.uppercased()
        assert(ARQuickLookController.supportedFormat.contains(format.uppercased()), "Format not provided, and guessed format from url is \(format), but is not supported. Please provide file format in settings dictionary.")
        settings["format"] = format
    }

    public func loadUrl(onPrepared: ((_ success: Bool) -> Void)? = nil) {
        if (loading || path != nil) {
            onPrepared?(path != nil)
            return
        }
        guard let url = settings["url"] else {return}
        guard let format = settings["format"] else {return}
        let uri = URL(string: url)!

        var req = URLRequest(url: uri)
        req.allHTTPHeaderFields = headers
        loading = true

        let task = URLSession.shared.dataTask(with: req) {(data, response, error) in
            guard let data = data else { return }
            //let ret = self.loadData(data, format: fmt)
            do {
                let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(uri.lastPathComponent).\(format.lowercased())")
                try data.write(to: path)
                self.path = path
                self.ensureFormat()
                self.loading = false
                if (onPrepared != nil) {
                    DispatchQueue.main.async {
                        onPrepared?(true)
                    }
                }
            } catch {
                self.loading = false
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

    public func launchAR(_ presenter: UIViewController?, completion: (() -> Void)? = nil) {
        loadUrl()
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
