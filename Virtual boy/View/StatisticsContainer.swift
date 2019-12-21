//
//  StatisticsContainer.swift
//  Virtual boy
//
//  Created by Fish on 20/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit

protocol DetailsContainerDelegate {
    func deleteButtonClicked(_ sender: UIButton)
}

class StatisticsContainer: UIView {
    
    var buttonsDelegate: DetailsContainerDelegate!
    
    let place: UILabel =
    {
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeueLT-Bold" , size: 8.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let locationIcon: UIImageView =
    {
        let view = UIImageView()
        let image = UIImage(named: "location")
        view.image = image
        view.sizeThatFits(CGSize(width: 25, height: 25))
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let deleteButton: UIButton =
    {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(.remove, for: .normal)
        btn.addTarget(self, action: #selector(deleteButtonClicked(_:)), for: .touchUpInside)
        return btn
    }()
    
    let stack: UIStackView =
    {
        let stck = UIStackView()
        stck.axis = .horizontal
        stck.distribution = .fill
        stck.alignment = .leading
        stck.spacing = 8
        stck.translatesAutoresizingMaskIntoConstraints = false
        return stck
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpContainer()
        configureStatisticsContainer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpContainer() {
        //set color to clear in order to limit the places where the change in color won't effect
        backgroundColor = .clear
    }
    
    private func configureStatisticsContainer() {
        //add views
//        self.addSubview(stack)
//        //stack.addSubview(locationIcon)
//        stack.addSubview(place)
//        stack.addSubview(deleteButton)
        //self.addSubview(locationIcon)
        self.addSubview(place)
        self.addSubview(deleteButton)
        
//        addConstraints([
//            stack.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
//            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
//            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
//            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4)
//        ])
        //set up views constraint
//        addConstraints([
//              locationIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//              locationIcon.trailingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4)
//          ])
        
        addConstraints([
            place.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            place.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4)
        ])

        addConstraints([
            deleteButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4)
        ])
        
    }
    
    func updateUI(title: String, date: Double) {
        self.place.text = title
    }
    
    //called when the comment icon is pressed
    @objc private func deleteButtonClicked (_ sender: UIButton) {
        buttonsDelegate.deleteButtonClicked(sender)
    }
    
    //caneled because flicker's api does not provide dates
    
//    func calculateTimeLapse(milliseconds: Double, isAbbreviated: Bool = true) -> String {
//
//        let abbrev = isAbbreviated ? "_abbrev" : ""
//
//        let totalSeconds = NSTimeIntervalSince1970 + Date.timeIntervalSinceReferenceDate - (milliseconds / 1000)
//
//        if totalSeconds != 0 {
//
//            let hours = totalSeconds / 3600
//
//            let yearsVal = hours / (24 * 30 * 12)
//            let monthsVal = (hours / (24 * 30)).truncatingRemainder(dividingBy: 12)
//            let daysVal = (hours / 24).truncatingRemainder(dividingBy: 30)
//            let hoursVal = hours.truncatingRemainder(dividingBy: 24)
//            let minutesVal  = (totalSeconds / 60).truncatingRemainder(dividingBy: 60)
//            let secondsVal = totalSeconds.truncatingRemainder(dividingBy: 60)
//
//            let numberFormatter = NumberFormatter()
//            let yearsText = numberFormatter.string(from: NSNumber(value: yearsVal))
//            let monthsText = numberFormatter.string(from: NSNumber(value: monthsVal))
//            let daysText = numberFormatter.string(from: NSNumber(value: daysVal))
//            let hoursText = numberFormatter.string(from: NSNumber(value: hoursVal))
//            let minutesText = numberFormatter.string(from: NSNumber(value: minutesVal))
//            let secondsText = numberFormatter.string(from: NSNumber(value: secondsVal))
//
//            var output: String {
//                if yearsVal >= 1 {
//                    return (yearsText! + NSLocalizedString("years\(abbrev)", comment: ""))
//                } else if monthsVal >= 1 {
//                    return (monthsText! + NSLocalizedString("months\(abbrev)", comment: ""))
//                } else if daysVal >= 1 {
//                    return (daysText! + NSLocalizedString("days\(abbrev)", comment: ""))
//                } else if hoursVal >= 1 {
//                    return (hoursText! + NSLocalizedString("hours\(abbrev)", comment: ""))
//                } else if minutesVal >= 1 {
//                    return (minutesText! + NSLocalizedString("minutes\(abbrev)", comment: ""))
//                } else if secondsVal >= 1 {
//                    return (secondsText! + NSLocalizedString("seconds\(abbrev)", comment: ""))
//                } else {
//                    return NSLocalizedString("now", comment: "")
//                }
//            }
//
//            return output
//        }
//
//        return ""
//
//    }
    
}
