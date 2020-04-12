//
//  ViewController.swift
//  ARQuickLook
//
//  Created by lapbay on 04/08/2020.
//  Copyright (c) 2020 lapbay. All rights reserved.
//

import UIKit
import ARQuickLook

class ViewController: UIViewController {
    private let translations: Dictionary<String, String> = [
    "Initializing": "正在初始化",
    "TRACKING UNAVAILABLE": "追踪不可用",
    "TRACKING NORMAL": "追踪正常",
    "TRACKING LIMITED\nExcessive motion": "追踪受限\n设备运动过激",
    "TRACKING LIMITED\nLow detail": "追踪受限\n低细节",
    "Recovering from interruption": "正在从中断中恢复",
    "Unknown tracking state.": "未知的追踪状态",
    "Try slowing down your movement, or reset the session.": "尝试慢些移动你的设备, 或重置 AR 会话.",
    "Try pointing at a flat surface, or reset the session.": "尝试对准一个平坦的表面, 或重置 AR 会话.",
    "Return to the location where you left off or try resetting the session.": "回到你刚才离开的位置, 或尝试重置 AR 会话.",
    "FIND A SURFACE TO PLACE AN OBJECT": "尝试找一个平面来放置模型",
    "TRY MOVING LEFT OR RIGHT": "尝试向左或向右移动一下",
    "TAP + TO PLACE AN OBJECT": "点击下方的 + 按钮放置模型",
    "SURFACE DETECTED": "已检测到平面",
    "CANNOT PLACE OBJECT\nTry moving left or right.": "无法放置模型\n尝试向左或向右移动一下"
    ]


    @available(iOS 13.0, *)
    func launch(url: String, format: String) -> ARQuickLookController {
        let settings: Dictionary<String, Any> = [
            "url": url,
            "format": format,
            "max": 10,
            "scale": 0.1,
            "gestures": ["scale": true, "rotate": false, "drag": true, "tap": false]
        ]
        let controller = ARQuickLookController(settings: settings)
        controller.translations = translations
        return controller
    }

    @available(iOS 13.0, *)
    func presentLoadingIndicator () {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }

    @available(iOS 13.0, *)
    @objc func httpLaunch () {
        presentLoadingIndicator()

        let controller = launch(url: "https://developer.apple.com/augmented-reality/quick-look/models/cupandsaucer/cup_saucer_set.usdz", format: "USDZ")
        controller.loadUrl { success in
            self.dismiss(animated: false) {
                controller.launchAR(nil) {
                    print("presented")
                }
            }
        }
    }

    @available(iOS 13.0, *)
    @objc func localLaunch () {
        presentLoadingIndicator()

        let uri = URL(string: "https://storage.googleapis.com/ar-answers-in-search-models/static/Tiger/model.glb")!
        let req = URLRequest(url: uri)

        let task = URLSession.shared.dataTask(with: req) {(data, response, error) in
            guard let data = data else { return }
            do {
                let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(uri.lastPathComponent)
                try data.write(to: path)
                DispatchQueue.main.async {
                    let controller = self.launch(url: path.absoluteString, format: "GLB")
                    self.dismiss(animated: false) {
                        controller.launchAR(nil) {
                            print("presented")
                        }
                    }
                }
            } catch {
                print("http error: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

    @available(iOS 13.0, *)
    @objc func bundleLaunch () {
        let modelsURL = Bundle.main.url(forResource: "Models.scnassets", withExtension: nil)!

        let fileEnumerator = FileManager().enumerator(at: modelsURL, includingPropertiesForKeys: [])!
        let extensions = ["obj", "dae", "abc", "ply", "stl", "scn"]

        let urls: [URL] = fileEnumerator.compactMap { element in
            let url = element as! URL

            guard extensions.contains(url.pathExtension) else { return nil }

            return url
        }

        let url = urls.randomElement()!

        let controller = launch(url: url.absoluteString, format: url.pathExtension.uppercased())
        controller.launchAR(nil) {
            print("presented")
        }
    }

    @available(iOS 13.0, *)
    func setupUI() {
        let sa = view.safeAreaLayoutGuide

        let http = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 48))
        http.backgroundColor = .systemBlue
        http.setTitle("AR QuickLook With Http Model", for: .normal)
        http.addTarget(self, action: #selector(httpLaunch), for: .touchUpInside)
        view.addSubview(http)
        http.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            http.centerXAnchor.constraint(equalTo: sa.centerXAnchor),
            http.topAnchor.constraint(equalTo: sa.topAnchor, constant: 100),
            http.widthAnchor.constraint(equalToConstant: 300),
            http.heightAnchor.constraint(equalToConstant: 48)
            ])

        let local = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 48))
        local.backgroundColor = .systemBlue
        local.setTitle("AR QuickLook With Local Model", for: .normal)
        local.addTarget(self, action: #selector(localLaunch), for: .touchUpInside)
        view.addSubview(local)
        local.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            local.centerXAnchor.constraint(equalTo: sa.centerXAnchor),
            local.topAnchor.constraint(equalTo: http.bottomAnchor, constant: 64),
            local.widthAnchor.constraint(equalToConstant: 300),
            local.heightAnchor.constraint(equalToConstant: 48)
            ])

        let bundle = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 48))
        bundle.backgroundColor = .systemBlue
        bundle.setTitle("AR QuickLook With Bundle Model", for: .normal)
        bundle.addTarget(self, action: #selector(bundleLaunch), for: .touchUpInside)
        view.addSubview(bundle)
        bundle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bundle.centerXAnchor.constraint(equalTo: sa.centerXAnchor),
            bundle.topAnchor.constraint(equalTo: local.bottomAnchor, constant: 64),
            bundle.widthAnchor.constraint(equalToConstant: 300),
            bundle.heightAnchor.constraint(equalToConstant: 48)
            ])

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            setupUI()
        } else {
            let label = UILabel()
            label.text = "ARQuickLook supports minimium iOS version of 13.0"
            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

