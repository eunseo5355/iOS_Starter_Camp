//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

@available(iOS 14.0, *)
class OpenMarketItemListViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var itemDetailButton: UIBarButtonItem!

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var collectionView: UICollectionView!
    private let listCellNibName = UINib(nibName: Cell.ReuseIdentifier.listCell, bundle: nil)
    private let gridCellNibName = UINib(nibName: Cell.ReuseIdentifier.gridCell, bundle: nil)
    private var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
    private let networkManager = NetworkManager(.shared)
    private var currentPage: Int = 0
    
    /// Page loads new items when the cell ends displaying (total item numbers - triggingPagingBound).
    /// See collectionView(_:didEndDisplaying:forItemAt:) for further understanding.
    private let triggingPagingBound: Int = 18
    // MARK: - Namespaces
    enum Section {
        case main
    }
    
    enum Cell {
        enum ReuseIdentifier {
            static let listCell: String = "ListCollectionViewCell"
            static let gridCell: String = "GridCollectionViewCell"
        }
        
        enum Layout {
            static let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                         heightDimension: .fractionalHeight(1.0))
            static let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .fractionalHeight(0.35))
            static let columnPerSection: Int = 2
            static let groupInterItemSpacing: NSCollectionLayoutSpacing = .fixed(CGFloat(10))
            static let sectionInterItemSpacing: CGFloat = CGFloat(10)
            static let sectionContentInset = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        }
        
        /// Determined by the segmented control index
        enum ViewMode {
            static let list: Int = 0
        }
        
        enum GridCellDesign {
            static let borderWidth = CGFloat(1.5)
            static let cornerRadius = CGFloat(10)
            static let borderColor: CGColor = UIColor.lightGray.cgColor
        }
        
        enum UIContents {
            static let defaultThumbnail = UIImage(systemName: "photo.fill")
            static let stockLabelTextColor: UIColor = .gray
            static let priceLabelTextColor: UIColor = .gray
            static let stockLabelBound: Int = 999
            static let stockLabelWhenExceedsBoundedSet: String = "잔여수량 : 999+"
            static let stockLabelWhenOutOfStock: String = "품절"
            static let stockLabelTextColorWhenOutOfStock: UIColor = .orange
            static let stockLabelForRemaining: String = "잔여수량 : "
        }
    }
    
    // MARK: - View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()

        configureHierarchy()
        configureDataSource()
        
        collectionView.register(listCellNibName, forCellWithReuseIdentifier: Cell.ReuseIdentifier.listCell)
        collectionView.register(gridCellNibName, forCellWithReuseIdentifier: Cell.ReuseIdentifier.gridCell)
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
}

// MARK: - Create Layouts as per View Mode
@available(iOS 14.0, *)
extension OpenMarketItemListViewController {
    private func createListViewLayout() -> UICollectionViewLayout {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }
    
    private func createGridViewLayout() -> UICollectionViewLayout {
        let itemSize = Cell.Layout.itemSize
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = Cell.Layout.groupSize
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitem: item,
                                                       count: Cell.Layout.columnPerSection)
        group.interItemSpacing = Cell.Layout.groupInterItemSpacing
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = Cell.Layout.sectionInterItemSpacing
        section.contentInsets = Cell.Layout.sectionContentInset
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: - Configure Hierarchy and DataSource as per View Mode
@available(iOS 14.0, *)
extension OpenMarketItemListViewController {
    private func configureHierarchy() {
        if viewModeSegmentedControl.selectedSegmentIndex == Cell.ViewMode.list {
            collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createListViewLayout())
        } else {
            collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createGridViewLayout())
        }
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        self.collectionView.delegate = self
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            var cell: OpenMarketCell?
            
            self.dequeueCellByViewMode(&cell, collectionView, indexPath)
            self.showActivityIndicatorUntilThumbnailLoadFinishes(cell, item)
            self.insertTextToLabels(to: cell, with: item)
            
            return cell as? UICollectionViewCell
        }
        
        guard snapshot.numberOfItems == 0 else {
            changeViewModeWithCurrentDataSource()
            return
        }

        self.snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        
        currentPage += 1
        loadItems(from: currentPage, networkManager)
    }
    
    // MARK: - Component Methods for Configuring Data Source
    private func dequeueCellByViewMode(_ cell: inout OpenMarketCell?,
                                       _ collectionView: UICollectionView,
                                       _ indexPath: IndexPath) {
        if self.viewModeSegmentedControl.selectedSegmentIndex == Cell.ViewMode.list {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.ReuseIdentifier.listCell,
                                                      for: indexPath) as! ListCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.ReuseIdentifier.gridCell,
                                                      for: indexPath) as! GridCollectionViewCell
            
            cell?.layer.borderWidth = Cell.GridCellDesign.borderWidth
            cell?.layer.cornerRadius = Cell.GridCellDesign.cornerRadius
            cell?.layer.borderColor = Cell.GridCellDesign.borderColor
        }
    }
    
    private func loadThumbnails(for cell: OpenMarketCell?, with item: Item) {
        if let data = try? Data(contentsOf: URL(string: item.thumbnails![0])!) {
            DispatchQueue.main.async {
                cell?.thumbnailImageView.image = UIImage(data: data)
            }
        } else {
            cell?.thumbnailImageView.image = Cell.UIContents.defaultThumbnail
        }
    }
    
    private func insertTextToLabels(to cell: OpenMarketCell?, with item: Item) {
        guard let price: Int = item.price else { return }
        guard let formattedPrice: String = price.formatInDecimalStyle() else { return }
        guard let currency: String = item.currency else { return }
        
        cell?.titleLabel.text = item.title
        
        if item.discountedPrice == nil {
            cell?.priceLabel.attributedText = NSAttributedString(
                string: "\(currency) \(formattedPrice)"
            )
            cell?.priceLabel.textColor = .gray
            cell?.discountedPriceLabel.isHidden = true
        } else {
            guard let discountedPrice = item.discountedPrice else { return }
            guard let formattedDiscountedPrice = discountedPrice.formatInDecimalStyle() else { return }
            cell?.priceLabel.attributedText = "\(currency) \(formattedPrice)".strikeThrough()
            cell?.priceLabel.textColor = .red
            cell?.discountedPriceLabel.text = currency + " \(formattedDiscountedPrice)"
            cell?.discountedPriceLabel.textColor = .gray
        }
        
        guard let stock = item.stock else { return }
        
        cell?.stockLabel.textColor = Cell.UIContents.stockLabelTextColor
        if stock > Cell.UIContents.stockLabelBound {
            cell?.stockLabel.text = Cell.UIContents.stockLabelWhenExceedsBoundedSet
        } else if stock == 0 {
            cell?.stockLabel.text = Cell.UIContents.stockLabelWhenOutOfStock
            cell?.stockLabel.textColor = Cell.UIContents.stockLabelTextColorWhenOutOfStock
        } else {
            cell?.stockLabel.text = Cell.UIContents.stockLabelForRemaining + "\(item.stock!)"
        }
    }
    
    /// This method contains the task for loading thumbnails.
    private func showActivityIndicatorUntilThumbnailLoadFinishes(_ cell: OpenMarketCell?, _ item: Item) {
        let thumbnailProcessingDispatchGroup = DispatchGroup()
        thumbnailProcessingDispatchGroup.enter()
        
        DispatchQueue.global().async {
            self.loadThumbnails(for: cell, with: item)
            
            thumbnailProcessingDispatchGroup.leave()
            
            DispatchQueue.main.async {
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func changeViewModeWithCurrentDataSource() {
        self.collectionView.register(listCellNibName, forCellWithReuseIdentifier: Cell.ReuseIdentifier.listCell)
        self.collectionView.register(gridCellNibName, forCellWithReuseIdentifier: Cell.ReuseIdentifier.gridCell)
        self.dataSource.apply(self.snapshot, animatingDifferences: false)
    }
    
    // MARK: - IBAction Methods
    @IBAction func onClickSegmentedControl(_ sender: UISegmentedControl) {
        viewDidLoad()
    }
}

// MARK: - CollectionView Delegate
@available(iOS 14.0, *)
extension OpenMarketItemListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.snapshot.numberOfItems - self.triggingPagingBound {
            currentPage += 1
            loadItems(from: currentPage, networkManager)
        }
    }
}

// MARK: - Networking
@available(iOS 14.0, *)
extension OpenMarketItemListViewController {
    private func loadItems(from page: Int, _ networkManager: NetworkManager) {
        networkManager.request(ItemList.self, url: OpenMarketURL.viewItemList(page).url) { result in
            switch result {
            case .success(let itemList):
                if itemList.items.isEmpty { return }
                
                self.snapshot.appendItems(itemList.items)
                self.dataSource.apply(self.snapshot, animatingDifferences: false)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
