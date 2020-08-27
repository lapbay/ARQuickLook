/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Popover view controller for choosing virtual objects to place in the AR scene.
*/

import UIKit
import ARKit

// MARK: - ObjectCell
@available(iOS 13.0, *)
extension UIImageView {
    func network(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        contentMode = .center
        tintColor = .systemPurple
        image = UIImage(systemName: "slowmo")
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.contentMode = mode
                self?.image = image
            }
        }.resume()
    }

    func network(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        network(from: url, contentMode: mode)
    }
}

@available(iOS 13.0, *)
class ObjectCell: UICollectionViewCell {
    static let reuseIdentifier = "ObjectCell"

    override var isSelected: Bool {
        didSet {
            checkmark.isHidden = !isSelected
        }
    }

    override init(frame: CGRect) {

        super.init(frame: frame)
        self.imageView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.checkmark.frame = CGRect(x: frame.size.width - 26, y: 0, width: 26, height: 24)

        let titleView = UIView()
        titleView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        titleView.frame = CGRect(x: 0, y: frame.size.height - 32, width: frame.size.width, height: 32)
        self.label.frame = CGRect(x: 6, y: 0, width: frame.size.width - 12, height: 32)
        titleView.addSubview(self.label)

        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(titleView)
        self.contentView.addSubview(checkmark)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var checkmark: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemPurple
        imageView.clipsToBounds = true
        imageView.isHidden = true
        return imageView
    }()

    var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .natural
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        //imageView.backgroundColor = .lightGray
        return imageView
    }()
}

// MARK: - VirtualObjectSelectionViewControllerDelegate

/// A protocol for reporting which objects have been selected.
@available(iOS 13.0, *)
protocol VirtualObjectSelectionViewControllerDelegate: class {
    func virtualObjectSelectionViewController(_ selectionViewController: VirtualObjectSelectionViewController, didSelectObject: VirtualObject)
    func virtualObjectSelectionViewController(_ selectionViewController: VirtualObjectSelectionViewController, didDeselectObject: VirtualObject)
}

/// A custom table view controller to allow users to select `VirtualObject`s for placement in the scene.
@available(iOS 13.0, *)
class VirtualObjectSelectionViewController: UICollectionViewController {
    
    /// The collection of `VirtualObject`s to select from.
    var virtualObjects = [AsyncVirtualObject]()
    
    /// The rows of the currently selected `VirtualObject`s.
    var selectedVirtualObjectRows = IndexSet()
    
    /// The rows of the 'VirtualObject's that are currently allowed to be placed.
    var enabledVirtualObjectRows = Set<Int>()
    
    weak var delegate: VirtualObjectSelectionViewControllerDelegate?
    
    weak var sceneView: ARSCNView?

    private var lastObjectAvailabilityUpdateTimestamp: TimeInterval?


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(collectionViewLayout: layout)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - ARPreview
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(ObjectCell.self, forCellWithReuseIdentifier: ObjectCell.reuseIdentifier)
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let spacing: CGFloat = 6
            layout.minimumLineSpacing = spacing
            layout.minimumInteritemSpacing = spacing
            layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
            let size = CGSize(width: 150, height: 150)
            layout.itemSize = size
        }
    }

    override func viewWillLayoutSubviews() {
        preferredContentSize = CGSize(width: 320, height: collectionView.contentSize.height)
    }

    func reload() {
        collectionView.reloadData()
    }

    func updateObjectAvailability() {
        guard let sceneView = sceneView else { return }
        
        // Update object availability only if the last update was at least half a second ago.
        if let lastUpdateTimestamp = lastObjectAvailabilityUpdateTimestamp,
            let timestamp = sceneView.session.currentFrame?.timestamp,
            timestamp - lastUpdateTimestamp < 0.5 {
            return
        } else {
            lastObjectAvailabilityUpdateTimestamp = sceneView.session.currentFrame?.timestamp
        }
                
        var newEnabledVirtualObjectRows = Set<Int>()
        // MARK: - ARPreview
        for (row, object) in virtualObjects.enumerated() {
            // Enable row always if item is already placed, in order to allow the user to remove it.
            if selectedVirtualObjectRows.contains(row) {
                newEnabledVirtualObjectRows.insert(row)
            }
            
            // Enable row if item can be placed at the current location
            if let query = sceneView.getRaycastQuery(for: object.allowedAlignment),
                let result = sceneView.castRay(for: query).first {
                object.mostRecentInitialPlacementResult = result
                object.raycastQuery = query
                newEnabledVirtualObjectRows.insert(row)
            } else {
                object.mostRecentInitialPlacementResult = nil
                object.raycastQuery = nil
            }
        }
        
        // Only reload changed rows
        let changedRows = newEnabledVirtualObjectRows.symmetricDifference(enabledVirtualObjectRows)
        enabledVirtualObjectRows = newEnabledVirtualObjectRows
        let indexPaths = changedRows.map { row in IndexPath(row: row, section: 0) }

        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: indexPaths)
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
        guard cellIsEnabled else { return }
        
        let object = virtualObjects[indexPath.row]
        
        // Check if the current row is already selected, then deselect it.
        if selectedVirtualObjectRows.contains(indexPath.row) {
            delegate?.virtualObjectSelectionViewController(self, didDeselectObject: object)
        } else {
            delegate?.virtualObjectSelectionViewController(self, didSelectObject: object)
        }

        self.collectionView.reloadItems(at: [indexPath])
        dismiss(animated: true, completion: nil)
    }
        
    // MARK: - UITableViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return virtualObjects.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // MARK: - ARPreview
        var c = collectionView.dequeueReusableCell(withReuseIdentifier: ObjectCell.reuseIdentifier, for: indexPath) as? ObjectCell
        if c == nil {
            c = ObjectCell()
        }
        guard let cell = c else {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: ObjectCell.reuseIdentifier, for: indexPath) as? ObjectCell else {
            fatalError("Expected `\(ObjectCell.self)` type for reuseIdentifier \(ObjectCell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        if let data = virtualObjects[indexPath.row].data {
            cell.label.text = data["t"]
            cell.imageView.network(from: data["tn"]!)
        }

        cell.isSelected = selectedVirtualObjectRows.contains(indexPath.row)
//        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
//        if cellIsEnabled {
//            cell.vibrancyView.alpha = 1.0
//        } else {
//            cell.vibrancyView.alpha = 0.1
//        }

        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
//        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
//        guard cellIsEnabled else { return }
//
//        let cell = tableView.cellForRow(at: indexPath)
//        cell?.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
//    }
//
//    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
//        let cellIsEnabled = enabledVirtualObjectRows.contains(indexPath.row)
//        guard cellIsEnabled else { return }
//
//        let cell = tableView.cellForRow(at: indexPath)
//        cell?.backgroundColor = .clear
//    }
}
