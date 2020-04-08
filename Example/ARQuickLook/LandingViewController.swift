//
//  LandingViewController.swift
//  ARKitInteraction
//
//  Created by Wu Chang on 2020/4/6.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation


import UIKit

class LandingViewController: UIViewController {
    static private let translations: Dictionary<String, String> = [
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 48))
        btn.backgroundColor = .systemBlue
        btn.setTitle("Launch AR View", for: .normal)
        btn.addTarget(self, action: #selector(launch), for: .touchUpInside)
        btn.center = view.center
        view.addSubview(btn)
    }

    @objc func launch () {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)

        let settings: Dictionary<String, Any> = [
            "url": "https://zcpri.oss-cn-qingdao.aliyuncs.com/specs/3295/0/tri/liu.glb",
            "format": "GLB",
            "max": 0.1,
            "gestures": ["scale": true, "rotate": false, "drag": true, "tap": false]
        ]
//        let settings = ["url": "https://zcpri.oss-cn-qingdao.aliyuncs.com/chair_swan.usdz", "format": "USDZ"]
        let controller = ARPreviewController(settings: settings)
        controller.translations = LandingViewController.translations
        controller.loadUrl { success in
            print(success)
            self.dismiss(animated: false) {
                controller.launchAR(nil) {
                    print("presented")
                }
            }
        }

    }

}

