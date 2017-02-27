//
//  EventsViewController.swift
//  Octowire
//
//  Created by Mart Roosmaa on 25/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import UIKit
import RxSwift
import ReSwift
import RxCocoa
import RxDataSources
import Kingfisher

private enum Row {
    case event(EventModel)
    case octocat
}

extension Row: IdentifiableType {
    var identity: String {
        switch self {
        case .event(let ev): return "event-\(ev.id)"
        case .octocat: return "octocat"
        }
    }
}

extension Row: Equatable {
    static func ==(lhs: Row, rhs: Row) -> Bool {
        switch lhs {
        case .event(let lhsEvent):
            if case .event(let rhsEvent) = rhs {
                return lhsEvent.id == rhsEvent.id
            }
        case .octocat:
            if case .octocat = rhs {
                return true
            }
        }
        return false
    }
}

private typealias RowModel = AnimatableSectionModel<String, Row>

class EventsBrowserViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterRepoButton: UIButton!
    @IBOutlet weak var filterStarButton: UIButton!
    @IBOutlet weak var filterPullRequestButton: UIButton!
    @IBOutlet weak var filterForkButton: UIButton!
    
    fileprivate let dataSource = RxCollectionViewSectionedAnimatedDataSource<RowModel>();
    fileprivate let disposeBag = DisposeBag()
    fileprivate let rows = Variable<[Row]>([])
    fileprivate let scrollTopDistance = Variable<Float32>(0.0)
    private var scrollSyncInitialised = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hookup the events to the collection view
        self.dataSource.configureCell = self.cellFactory
        self.rows.asObservable()
            .map({ rows in [RowModel(model: "", items: rows)] })
            .bindTo(self.collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        self.collectionView.delegate = self
        
        // Hook up filter buttons to generate active filter update actions
        Observable.of(
            self.filterRepoButton.rx.tap.map({ EventsFilter.repoEvents }),
            self.filterStarButton.rx.tap.map({ EventsFilter.starEvents }),
            self.filterPullRequestButton.rx.tap.map({ EventsFilter.pullRequestEvents }),
            self.filterForkButton.rx.tap.map({ EventsFilter.forkEvents }))
            .merge()
            .subscribe { ev in
                guard let filter = ev.element else {
                    return
                }
                
                var activeFilters = mainStore.state.eventsBrowserState.activeFilters
                if let idx = activeFilters.index(of: filter) {
                    activeFilters.remove(at: idx)
                } else {
                    activeFilters.append(filter)
                }
                
                mainStore.dispatch(EventsBrowserActionUpdateActiveFilters(to: activeFilters))
            }
            .disposed(by: self.disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Wait for UICollectionView to have populated with cells before
        // enabling scroll position sync. Otherwise, UICollectionView
        // will emit a new scroll position as the views are displayed.
        if self.rows.value.count > 0 && !self.scrollSyncInitialised {
            self.scrollSyncInitialised = true
            
            self.scrollTopDistance.asObservable()
                .map({ CGPoint(x: 0, y: CGFloat($0)) })
                .filter({ self.collectionView.contentOffset != $0 })
                .bindTo(self.collectionView.rx.contentOffset)
                .disposed(by: self.disposeBag)
            
            self.collectionView.rx.contentOffset.asObservable()
                .map({ Float32($0.y) })
                .filter({
                    self.scrollTopDistance.value != $0
                })
                .subscribe { ev in
                    let topDistance = ev.element ?? 0
                    mainStore.dispatch(EventsBrowserActionUpdateScrollTopDistance(to: topDistance))
                }
                .disposed(by: self.disposeBag)
        }
    }
    
    private func cellFactory(dataSource: CollectionViewSectionedDataSource<RowModel>,
                             collectionView: UICollectionView,
                             indexPath: IndexPath,
                             row: Row) -> UICollectionViewCell {
        
        switch dataSource[indexPath] {
        case .event(let ev):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as! EventsViewEventCell
            cell.bind(model: ev)
            return cell
            
        case .octocat:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "octocatCell", for: indexPath)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainStore.subscribe(self) { $0.eventsBrowserState }
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainStore.dispatch(EventsBrowserActionUpdateIsVisible(to: true))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mainStore.unsubscribe(self)
        mainStore.dispatch(EventsBrowserActionUpdateIsVisible(to: false))
        
        super.viewWillDisappear(animated)
    }
}

extension EventsBrowserViewController: StoreSubscriber {
    func newState(state: EventsBrowserState) {
        rows.value = state.filteredEvents.map({ .event($0) }) + [.octocat]
        scrollTopDistance.value = state.scrollTopDistance
        
        configureFilterButton(self.filterRepoButton, filter: .repoEvents, state: state)
        configureFilterButton(self.filterStarButton, filter: .starEvents, state: state)
        configureFilterButton(self.filterForkButton, filter: .forkEvents, state: state)
        configureFilterButton(self.filterPullRequestButton, filter: .pullRequestEvents, state: state)
    }
    
    private func configureFilterButton(_ button: UIButton, filter: EventsFilter, state: EventsBrowserState) {
        if state.activeFilters.contains(filter) {
            button.tintColor = AppColor.blue
            button.isSelected = true
        } else {
            button.tintColor = AppColor.lightGray
            button.isSelected = false
        }
    }
}

extension EventsBrowserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let maxWidth = collectionView.frame.width
        
        switch self.dataSource[indexPath] {
        case .event(_): return CGSize(width: maxWidth, height: 64)
        case .octocat: return CGSize(width: maxWidth, height: 82)
        }
    }
}

class EventsViewEventCell: UICollectionViewCell {
    @IBOutlet weak var actorImage: UIImageView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func awakeFromNib() {
        self.actorImage.layer.cornerRadius = 10.0
        
        reset()
    }
    
    override func prepareForReuse() {
        reset()
    }
    
    private func reset() {
        self.actorImage.image = nil
        self.summaryLabel.text = ""
        self.iconImage.image = nil
    }
    
    public func bind(model: EventModel) {
        self.actorImage.kf
            .setImage(with: model.actorAvatarUrl,
                      placeholder: #imageLiteral(resourceName: "AvatarPlaceholder"),
                      options: [],
                      progressBlock: nil,
                      completionHandler: nil)
        
        let eventIcon: UIImage?
        let summaryText: NSAttributedString
        switch model {
        case let ev as CreateEventModel:
            eventIcon = #imageLiteral(resourceName: "RepositoryIcon")
            summaryText = NSAttributedString(string: "\(ev.actorUsername ?? "someone") created repository \(ev.repoName ?? "a-repo")")
            
        case let ev as WatchEventModel:
            eventIcon = #imageLiteral(resourceName: "StarIcon")
            summaryText = NSAttributedString(string: "\(ev.actorUsername ?? "someone") starred \(ev.repoName ?? "a-repo")")
            
        case let ev as ForkEventModel:
            eventIcon = #imageLiteral(resourceName: "ForkIcon")
            summaryText = NSAttributedString(string: "\(ev.actorUsername ?? "someone") forked \(ev.repoName ?? "a-repo") to \(ev.actorUsername ?? "someone")/\(ev.forkRepoName ?? "a-repo")")
            
        case let ev as PullRequestEventModel:
            eventIcon = #imageLiteral(resourceName: "PullRequestIcon")
            summaryText = NSAttributedString(string: "\(ev.actorUsername ?? "someone") opened pull request \(ev.repoName ?? "a-repo")#\(ev.pullRequestNumber ?? 0)")
            
        default:
            eventIcon = nil
            summaryText = NSAttributedString(string: "Event #\(model.id)")
        }
        
        self.iconImage.image = eventIcon
        self.summaryLabel.attributedText = summaryText
    }
}

class EventsViewOctocatCell: UICollectionViewCell {
    @IBOutlet weak var octocatImage: UIImageView!
    
    override func awakeFromNib() {
        reset()
    }
    
    override func prepareForReuse() {
        reset()
    }
    
    private func reset() {
        // Animate octocat doing the shake
        let easeIn = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        let easeOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let shakeStartDelay = 0.3
        let shakeDuration = 0.3
        let shakeEndDelay = 1.2
        
        let animLeftShake = CABasicAnimation(keyPath: "transform.rotation")
        animLeftShake.fromValue = 0
        animLeftShake.toValue = M_PI / 16
        animLeftShake.beginTime = shakeStartDelay
        animLeftShake.duration = shakeDuration / 4
        animLeftShake.autoreverses = true
        animLeftShake.timingFunction = easeIn
        
        let animRightShake = CABasicAnimation(keyPath: "transform.rotation")
        animRightShake.fromValue = 0
        animRightShake.toValue = -M_PI / 16
        animRightShake.beginTime = shakeStartDelay + shakeDuration / 2
        animRightShake.duration = shakeDuration / 4
        animRightShake.autoreverses = true
        animRightShake.timingFunction = easeOut
        
        let animGroup = CAAnimationGroup()
        animGroup.duration = shakeStartDelay + shakeDuration + shakeEndDelay
        animGroup.repeatCount = .infinity
        animGroup.animations = [animLeftShake, animRightShake]
        
        octocatImage.layer.add(animGroup, forKey: "octoShake")
    }
}
