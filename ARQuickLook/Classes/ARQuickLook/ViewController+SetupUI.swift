/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Methods on the main view controller for conforming to the ARCoachingOverlayViewDelegate protocol
*/

import UIKit
import ARKit


/// - Tag: Code Setup
@available(iOS 13.0, *)
extension ViewController {

    // MARK: - VirtualObjectSelectionViewControllerDelegate
    func removeObject(_ object: VirtualObject) {
        guard let objectIndex = virtualObjectLoader.loadedObjects.firstIndex(of: object) else {
            print("Programmer error: Failed to lookup virtual object in scene.")
            return
        }
        virtualObjectLoader.removeVirtualObject(at: objectIndex)
        virtualObjectInteraction.selectedObject = nil
        if let anchor = object.anchor {
            session.remove(anchor: anchor)
        }
    }

    // - Tag: PlaceVirtualContent
    func showObject(_ object: AsyncVirtualObject) {
        virtualObjectLoader.loadNetworkVirtualObject(object, loadedHandler: { [unowned self] scene in
            guard let loaded = scene else { return }
            self.sceneView.prepare([loaded], completionHandler: { _ in
                DispatchQueue.main.async {
                    self.hideObjectLoadingUI()
                    self.placeVirtualObject(object)
                }
            })
        })
        DispatchQueue.main.async {
            self.displayObjectLoadingUI()
        }
    }

    func showBundleObject(_ object: VirtualObject) {
        virtualObjectLoader.loadVirtualObject(object, loadedHandler: { [unowned self] loadedObject in

            do {
                let scene = try SCNScene(url: object.referenceURL, options: nil)
                self.sceneView.prepare([scene], completionHandler: { _ in
                    DispatchQueue.main.async {
                        self.hideObjectLoadingUI()
                        self.placeVirtualObject(loadedObject)
                    }
                })
            } catch {
                fatalError("Failed to load SCNScene from object.referenceURL")
            }

        })
        displayObjectLoadingUI()
    }

    @objc private func toggleVirtualObjects() {
        guard !addObjectButton.isHidden && !virtualObjectLoader.isLoading else { return }
        guard let ctl = controller else { return }

        statusViewController.cancelScheduledMessage(for: .contentPlacement)
        if ctl.models.count > 1 {
            self.preparePopover()
        }else if ctl.models.count > 0 {
            self.toggleVirtualObject()
        }
    }

    func preparePopover() {
        guard let ctl = controller else { return }
        let models = ctl.models
//        guard let url = ctl.path else { return }
        if availableObjects.count != models.count {
            for item in models {
                let object = AsyncVirtualObject(item)!
                if let m = ctl.settings["zoom"], let n = NumberFormatter().number(from: m)?.floatValue {
                    object.zoom = n
                }
                if let m = ctl.settings["max"], let n = NumberFormatter().number(from: m)?.floatValue {
                    object.maxSizeInMeters = n
                    if object.maxSizeInMeters > 10 {
                        object.maxSizeInMeters = 10
                    }
                }
                if let query = sceneView.getRaycastQuery(for: object.allowedAlignment),
                    let result = sceneView.castRay(for: query).first {
                    object.mostRecentInitialPlacementResult = result
                    object.raycastQuery = query
                } else {
                    object.mostRecentInitialPlacementResult = nil
                    object.raycastQuery = nil
                }
                availableObjects.append(object)
            }
        }

        let objectsViewController = VirtualObjectSelectionViewController()
        objectsViewController.virtualObjects = availableObjects as! [AsyncVirtualObject]
        objectsViewController.delegate = self
        objectsViewController.sceneView = sceneView
        objectsViewController.modalTransitionStyle = .coverVertical
        objectsViewController.modalPresentationStyle = .popover
        self.objectsViewController = objectsViewController

//        guard let objectsViewController = self.objectsViewController else { return }
        objectsViewController.updateObjectAvailability()
        objectsViewController.selectedVirtualObjectRows.removeAll()
        for object in virtualObjectLoader.loadedObjects {
            guard let index = availableObjects.firstIndex(of: object) else { continue }
            objectsViewController.selectedVirtualObjectRows.insert(index)
        }

        if let popoverController = objectsViewController.popoverPresentationController {
            popoverController.delegate = self
            popoverController.sourceView = addObjectButton
            popoverController.sourceRect = addObjectButton.bounds
        }
        sceneView.pause(nil)
        self.present(objectsViewController, animated: true, completion: nil)
    }


    @objc private func toggleVirtualObject() {
        for object in virtualObjectLoader.loadedObjects {
            removeObject(object)
        }

        guard let ctl = controller else { return }
        let item = ctl.models.first!
        let object = AsyncVirtualObject(item)!
        if let m = ctl.settings["zoom"], let n = NumberFormatter().number(from: m)?.floatValue {
            object.zoom = n
        }
        if let m = ctl.settings["max"], let n = NumberFormatter().number(from: m)?.floatValue {
            object.maxSizeInMeters = n
            if object.maxSizeInMeters > 10 {
                object.maxSizeInMeters = 10
            }
        }
        if let query = sceneView.getRaycastQuery(for: object.allowedAlignment),
            let result = sceneView.castRay(for: query).first {
            object.mostRecentInitialPlacementResult = result
            object.raycastQuery = query
            showObject(object)
        } else {
            object.mostRecentInitialPlacementResult = nil
            object.raycastQuery = nil
        }
    }

    // Set up UI by code
    func setupUI() {
        view.addSubview(sceneView)
        view.addSubview(blurView)
        view.addSubview(upperControlsView)
        view.addSubview(addObjectButton)
        view.addSubview(spinner)
        view.addSubview(closeButton)

        let sa = view.safeAreaLayoutGuide

        sceneView.isTemporalAntialiasingEnabled = true
        sceneView.loops = true
        sceneView.clearsContextBeforeDrawing = true
        sceneView.clipsToBounds = true
        sceneView.autoresizesSubviews = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: sa.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: sa.trailingAnchor)
            ])

        blurView.isHidden = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])

        upperControlsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            upperControlsView.topAnchor.constraint(equalTo: sa.topAnchor),
            upperControlsView.heightAnchor.constraint(equalToConstant: 85),
            upperControlsView.leadingAnchor.constraint(equalTo: sa.leadingAnchor),
            upperControlsView.trailingAnchor.constraint(equalTo: sa.trailingAnchor)
            ])

        addObjectButton.addTarget(self, action: #selector(toggleVirtualObjects), for: .touchUpInside)
        addObjectButton.tintColor = .white
        addObjectButton.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: [])
        addObjectButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addObjectButton.centerXAnchor.constraint(equalTo: sa.centerXAnchor),
            addObjectButton.bottomAnchor.constraint(equalTo: sa.bottomAnchor),
            addObjectButton.widthAnchor.constraint(equalToConstant: 48),
            addObjectButton.heightAnchor.constraint(equalToConstant: 48)
            ])

        spinner.isHidden = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: addObjectButton.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: addObjectButton.centerYAnchor),
            spinner.widthAnchor.constraint(equalTo: addObjectButton.widthAnchor, multiplier: 1, constant: -5),
            spinner.heightAnchor.constraint(equalTo: addObjectButton.heightAnchor, multiplier: 1, constant: -5)
            ])

        let status = StatusViewController()
        status.view.translatesAutoresizingMaskIntoConstraints = false
        status.messageLabel.translations = controller?.translations
        addChild(status)
        upperControlsView.addSubview(status.view)
        NSLayoutConstraint.activate([
            status.view.topAnchor.constraint(equalTo: upperControlsView.topAnchor),
            status.view.bottomAnchor.constraint(equalTo: upperControlsView.bottomAnchor),
            status.view.leadingAnchor.constraint(equalTo: upperControlsView.leadingAnchor),
            status.view.trailingAnchor.constraint(equalTo: upperControlsView.trailingAnchor)
            ])

        closeButton.addTarget(self, action: #selector(letsDismiss), for: .touchUpInside)
        closeButton.tintColor = .white
        closeButton.setBackgroundImage(UIImage(systemName: "multiply.circle.fill"), for: [])
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: sa.leadingAnchor, constant: 16),
            closeButton.bottomAnchor.constraint(equalTo: sa.bottomAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 48),
            closeButton.heightAnchor.constraint(equalToConstant: 48)
            ])

        if let settings = controller?.settings {
            virtualObjectInteraction.disableGestures(settings)
        }

        guard let ctl = controller else {return}
        if let m = ctl.settings["lighting"], m == "true" {
            sceneView.autoenablesDefaultLighting = true
            sceneView.automaticallyUpdatesLighting = false
        }
    }

    /// - Tag: App Lifecycle Observers
    func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func destroyObserver() {
        NotificationCenter.default.removeObserver(self)
    }


    @objc func applicationWillResignActive(_ application: UIApplication) {
        blurView.isHidden = false
    }

    @objc func applicationDidBecomeActive(_ application: UIApplication) {
        blurView.isHidden = true
    }

    @objc func letsDismiss() {
        dismiss(animated: true, completion: nil)
    }

}
