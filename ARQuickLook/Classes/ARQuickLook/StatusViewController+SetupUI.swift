/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Methods on the main view controller for conforming to the ARCoachingOverlayViewDelegate protocol
*/

import UIKit
import ARKit


class LocalizedLabel: UILabel {
    public var translations: Dictionary<String, String>? = nil

    open func localizedText(_ text: String) {
        if let trans = translations, let t = trans[text] {
            self.text = t
            return
        }
        self.text = text
    }
}


/// - Tag: Code Setup
@available(iOS 13.0, *)
extension StatusViewController {

    @objc private func restartSession(_ sender: UIButton) {
        restartExperienceHandler()
    }

    func setupUI() {
        // Set up UI by code
//        view.backgroundColor = .systemBlue
        view.addSubview(messagePanel)

        let visual = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light), style: .label))
        visual.contentView.addSubview(messageLabel)
        messagePanel.contentView.addSubview(visual)
        view.addSubview(restartExperienceButton)

        let sa = view.safeAreaLayoutGuide

        restartExperienceButton.addTarget(self, action: #selector(restartSession), for: .touchUpInside)
        restartExperienceButton.tintColor = .white
        restartExperienceButton.setImage(UIImage(systemName: "arrow.2.circlepath"), for: [])
//        restartExperienceButton.setImage(UIImage(systemName: "arrow.clockwise", withConfiguration: UIImage.SymbolConfiguration(weight: .bold)), for: .highlighted)
        restartExperienceButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            restartExperienceButton.topAnchor.constraint(equalTo: sa.topAnchor),
            restartExperienceButton.trailingAnchor.constraint(equalTo: sa.trailingAnchor, constant: -8),
            restartExperienceButton.widthAnchor.constraint(equalToConstant: 44),
            restartExperienceButton.heightAnchor.constraint(equalToConstant: 59)
            ])

        messagePanel.isHidden = true
        messagePanel.layer.cornerRadius = 5
        messagePanel.clipsToBounds = true
        messagePanel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messagePanel.centerYAnchor.constraint(equalTo: restartExperienceButton.centerYAnchor),
            messagePanel.leadingAnchor.constraint(equalTo: sa.leadingAnchor, constant: 16),
            messagePanel.trailingAnchor.constraint(lessThanOrEqualTo: restartExperienceButton.leadingAnchor, constant: -16),
            ])

        visual.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            visual.topAnchor.constraint(equalTo: messageLabel.topAnchor),
            visual.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor),
            visual.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            visual.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor)
            ])

        messageLabel.numberOfLines = 3
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: messagePanel.centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: messagePanel.centerYAnchor),
            messageLabel.widthAnchor.constraint(equalTo: messagePanel.widthAnchor, constant: -32),
            messageLabel.heightAnchor.constraint(equalTo: messagePanel.heightAnchor, constant: -16)
            ])

    }
}
