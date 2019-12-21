//
//  GrandVC.swift
//  Virtual boy
//
//  Created by Fish on 20/12/2019.
//  Copyright © 2019 Fish. All rights reserved.
//

import UIKit

class GrandVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, PresentNewViews {
    
    lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.insertSegment(withTitle: "Grid", at: 0, animated: false)
        control.insertSegment(withTitle: "Timeline", at: 1, animated: false)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentedControlDidChange(_:)), for: .valueChanged)
        return control
    }()
    
    let menuBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    let menuBarHeight: CGFloat = 50
    
    //Cells details
    let gridCellId = "gridCellId"
    let timelineCellId = "timelineCellId"
    var timelineViewCell: TimelineContainerCell?
    var gridViewCell: GridContainerCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureCollectionView()
        setUpViews()
        
        // Do any additional setup after loading the view.
    }
    
    private func configureNavigationBar() {
        // Setting the nav bar color and label
        self.navigationController?.navigationBar.isTranslucent = false
        navigationItem.title = "Memories"
    }
    
    private func configureCollectionView() {
        // setting up the collection view layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        
        // setting up the collection view
        collectionView.contentInset = UIEdgeInsets(top: menuBarHeight , left: 0, bottom: 0, right: 0 )
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: menuBarHeight , left: 0, bottom: 0, right: 0 )
        collectionView.isPagingEnabled = true
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .black
        
        // register collection view cells
        collectionView.register(GridContainerCell.self, forCellWithReuseIdentifier: gridCellId)
        collectionView.register(TimelineContainerCell.self, forCellWithReuseIdentifier: timelineCellId)
    }
    
    private func setUpViews() {
        // add the segmnted control
        menuBar.addSubview(segmentedControl)
        menuBar.addConstraints([
            segmentedControl.centerYAnchor.constraint(equalTo: menuBar.centerYAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: menuBar.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: menuBar.trailingAnchor, constant: -16)
        ])
        
        // add the header
        view.addSubview(menuBar)
        view.addConstraints([
            menuBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            menuBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            menuBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            menuBar.heightAnchor.constraint(equalToConstant: menuBarHeight)
        ])
        
    }
    
    //gets called every time the segmented control change
    @objc func segmentedControlDidChange(_ sender: UISegmentedControl) {
        scrollToPageIndex(pageIndex: sender.selectedSegmentIndex)
    }
    
    func scrollToPageIndex(pageIndex: Int) {
        // change the view once the segment is changed
        let indexPath = NSIndexPath(item: pageIndex, section: 0)
        collectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
        
        //stop and resume videos when going in/out of timeline view + reload views in order for the fetch calls to happen if needed
        if pageIndex == 0 {
            
            gridViewCell?.collectionView.reloadData()
        } else {
            
            timelineViewCell?.collectionView.reloadData()
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // change the segment index when scrolling to another view
        let index = targetContentOffset.move().x / view.frame.width
        segmentedControl.selectedSegmentIndex = Int(index)
        
        //stop and resume videos when going in/out of timeline view + reload views in order for the fetch calls to happen if needed
        if index == 0 {
            gridViewCell?.collectionView.reloadData()
        } else {
            timelineViewCell?.collectionView.reloadData()
        }
    }
    
    func moveToTImelineView(index: IndexPath) {
        //move and set the UI
        let indexPath = NSIndexPath(item: 1, section: 0)
        collectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
        segmentedControl.selectedSegmentIndex = 1
        
        //scroll to item + a bit of latency if it was the first time in order for the timeline view to be initialized
        if let _ = self.timelineViewCell?.collectionView.visibleCells {
            self.timelineViewCell?.collectionView.scrollToItem(at: index, at: .top, animated: false)
        } else {
            //Scroll after delay wating for timeline cells to be visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.timelineViewCell?.collectionView.scrollToItem(at: index, at: .top, animated: false)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //dequeueing cells depnding on what segment index
        if indexPath.item == 1
        {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: timelineCellId, for: indexPath) as? TimelineContainerCell {
                //assign delgate and media coordinator
                self.timelineViewCell = cell
            }
            return timelineViewCell ?? UICollectionViewCell()
        } else {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: gridCellId, for: indexPath) as? GridContainerCell {
                //assign delgate and media coordinator
                cell.presentDelgate = self
                self.gridViewCell = cell
            }
            return gridViewCell ?? UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //set size to the entire screen
        return CGSize(width: view.frame.width, height: collectionView.frame.height - menuBarHeight )
    }
    
    
}
