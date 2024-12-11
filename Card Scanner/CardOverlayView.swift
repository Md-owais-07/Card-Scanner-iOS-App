//
//  CardOverlayView.swift
//  Card Scanner
//
//  Created by Owais on 05/08/24.
//

import UIKit

class CardOverlayView: UIView {
    
    override func draw(_ rect: CGRect) {
        // Fill the whole view with a translucent black color
        UIColor.black.withAlphaComponent(0.6).setFill()
        UIRectFill(rect)
        
        // Set the card's frame with rounded corners
        let cardWidth = rect.width * 0.85
        let cardHeight = rect.height * 0.25
        let cardX = (rect.width - cardWidth) / 2
        let cardY = (rect.height - cardHeight) / 2
        let cardRect = CGRect(x: cardX, y: cardY, width: cardWidth, height: cardHeight)
        let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 10)
        
        // Create the combined path for the mask
        let combinedPath = UIBezierPath(rect: rect)
        combinedPath.append(cardPath)
        combinedPath.usesEvenOddFillRule = true
        
        // Apply the mask
        let fillRuleLayer = CAShapeLayer()
        fillRuleLayer.path = combinedPath.cgPath
        fillRuleLayer.fillRule = .evenOdd
        fillRuleLayer.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        layer.mask = fillRuleLayer
        
        // Add instruction text
        let instructionLabel = UILabel(frame: CGRect(x: 0, y: cardY - 40, width: rect.width, height: 30))
        instructionLabel.text = "Align your card within the frame"
        instructionLabel.textColor = .white
        instructionLabel.font = UIFont.boldSystemFont(ofSize: 17)
        instructionLabel.textAlignment = .center
        addSubview(instructionLabel)
    }
    
    // Allow touches to pass through the transparent area
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let cardWidth = bounds.width * 0.85
        let cardHeight = bounds.height * 0.25
        let cardX = (bounds.width - cardWidth) / 2
        let cardY = (bounds.height - cardHeight) / 2
        let cardRect = CGRect(x: cardX, y: cardY, width: cardWidth, height: cardHeight)
        return !cardRect.contains(point)
    }
}
