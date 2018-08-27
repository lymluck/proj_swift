//
//  CourseOutlineItem.swift
//  xxd
//
//  Created by remy on 2018/1/22.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

class CourseOutlineItem: SSCellItem {
    
    var model: CourseOutlineModel!
    var index = 0
    var durationString: String {
        return CourseOutlineItem.durationString(model.duration)
    }
    weak var currentCell: CourseOutlineCell?
    
    override init!(attributes: [AnyHashable : Any]! = [:]) {
        super.init(attributes: attributes)
        NotificationCenter.default.addObserver(self, selector: #selector(hasWatchVideo(notification:)), name: NSNotification.Name(rawValue: XD_NOTIFY_HAS_WATCH_VIDEO), object: nil)
    }
    
    override init!(cellClass: AnyClass!, userInfo: Any!) {
        super.init(cellClass: cellClass, userInfo: userInfo)
    }
    
    override func cellClass() -> AnyClass! {
        return model.chapterName.isEmpty ? CourseOutlineCell.self : CourseOutlineWithChapterCell.self
    }
    
    private static func durationString(_ d: Double) -> String {
        var duration = d / 1000
        if duration - duration.rounded(.down) > 0.8 {
            duration = duration.rounded(.down) + 1
        } else {
            duration = duration.rounded(.down)
        }
        var durationStr = ""
        if duration >= 3600 {
            let hour = Int(duration) / 3600
            let tmpMinute = Int(duration) % 3600
            let minute = tmpMinute / 60
            let second = tmpMinute % 60
            durationStr = String(format: "%02d:%02d:%02d", hour, minute, second)
        } else {
            let minute = Int(duration) / 60
            let second = Int(duration) % 60
            durationStr = String(format: "%02d:%02d", minute, second)
        }
        return durationStr
    }
    
    func updateProgress() {
        if let currentCell = currentCell {
            currentCell.updateProgress()
        }
    }
    
    //MARK:- Notification
    @objc func hasWatchVideo(notification: Notification) {
        if (notification.userInfo!["classID"] as! Int) == model.ID {
            let currentTime = notification.userInfo!["currentTime"] as! Double
            model.lastPlayTime = currentTime
            model.maxPlayTime = max(model.maxPlayTime, currentTime)
            let isNearlyFinish = (model.duration - model.maxPlayTime) <= min(30000, model.duration)
            model.progress = isNearlyFinish ? 100 : 100 * (model.maxPlayTime / model.duration)
            updateProgress()
        }
    }
}

class CourseOutlineCellProgressView: UIView {
    
    private var initialImageView: UIImageView!
    private var doneImageView: UIImageView!
    private var progressLayer: CAShapeLayer!
    private lazy var inProgressLayer: CALayer = {
        let layer = CALayer()
        let offset = width * 0.5
        let bgCircle = UIBezierPath(arcCenter: CGPoint(x: offset, y: offset), radius: offset, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5, clockwise: true)
        let circle = UIBezierPath(arcCenter: CGPoint(x: offset, y: offset), radius: width * 0.25, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi * 1.5, clockwise: true)
        
        let bgLayer = CAShapeLayer()
        bgLayer.frame = CGRect(x: 0, y: 0, width: width, height: width);
        bgLayer.position = CGPoint(x: offset, y: offset);
        bgLayer.fillColor = UIColor.white.cgColor
        bgLayer.lineWidth = 1;
        bgLayer.strokeColor = XDColor.main.cgColor;
        bgLayer.strokeStart = 0;
        bgLayer.strokeEnd = 1;
        bgLayer.path = bgCircle.cgPath;
        layer.addSublayer(bgLayer)
        
        progressLayer = CAShapeLayer()
        progressLayer.frame = CGRect(x: 0, y: 0, width: width, height: width);
        progressLayer.position = CGPoint(x: offset, y: offset);
        progressLayer.fillColor = UIColor.clear.cgColor

        progressLayer.lineWidth = offset;
        progressLayer.strokeColor = XDColor.main.cgColor;
        progressLayer.strokeStart = 0;
        progressLayer.strokeEnd = 0;
        progressLayer.path = circle.cgPath;
        layer.addSublayer(progressLayer)
        self.layer.addSublayer(layer)
        
        return layer
    }()
    var progress = -1.0 {
        didSet {
            if oldValue != progress {
                if progress == 0 {
                    initialImageView.isHidden = false
                    inProgressLayer.isHidden = true
                    doneImageView.isHidden = true
                } else if progress == 100 {
                    initialImageView.isHidden = true
                    inProgressLayer.isHidden = true
                    doneImageView.isHidden = false
                } else {
                    initialImageView.isHidden = true
                    inProgressLayer.isHidden = false
                    doneImageView.isHidden = true
                }
                progressLayer.strokeEnd = CGFloat(progress / 100)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        
        initialImageView = UIImageView(frame: bounds, imageName: "course_progress_zero")
        addSubview(initialImageView)
        
        doneImageView = UIImageView(frame: bounds, imageName: "course_progress_done")
        doneImageView.isHidden = true
        addSubview(doneImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CourseOutlineCell: SSTableViewCell {
    
    var container: UIView!
    private var titleLabel: UILabel!
    private var durationLabel: UILabel!
    private var progressView: CourseOutlineCellProgressView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        container = UIView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 48))
        contentView.addSubview(container)
        
        progressView = CourseOutlineCellProgressView(frame: CGRect(x: 16, y: 17, width: 14, height: 14))
        container.addSubview(progressView)
        
        titleLabel = UILabel(frame: CGRect(x: 38, y: 0, width: XDSize.screenWidth - 88, height: 48), text: "", textColor: UIColor(0x58646E), fontSize: 14)
        container.addSubview(titleLabel)
        
        durationLabel = UILabel(text: "", textColor: XDColor.itemText, fontSize: 14)
        container.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { (make) in
            make.right.equalTo(container).offset(-16)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 48
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? CourseOutlineItem {
            object.currentCell = self
            titleLabel.text = object.model.name
            durationLabel.text = object.durationString
            progressView.progress = object.model.progress
        }
        return true
    }
    
    func updateProgress() {
        progressView.progress = (item as! CourseOutlineItem).model.progress
    }
}

class CourseOutlineCellChapterView: UIControl {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.backgroundColor = XDColor.mainBackground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            // 点击整个 UITableViewCell 时,禁用 backgroundColor
        }
    }
}

class CourseOutlineWithChapterCell: CourseOutlineCell {
    
    private var topLine: UIView!
    private var chapterTitleLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        container.top = 48
        

        // UIControl 挡住点击区域
        let chapterView = CourseOutlineCellChapterView(frame: CGRect(x: 0, y: 0, width: XDSize.screenWidth, height: 48))
        contentView.addSubview(chapterView)
        
        chapterTitleLabel = UILabel(frame: CGRect(x: 16, y: 16, width: XDSize.screenWidth - 32, height: 32), text: "", textColor: XDColor.itemTitle, fontSize: 16)

        contentView.addSubview(chapterTitleLabel)
        
        topLine = UIView(frame: CGRect(x: 16, y: 0, width: XDSize.screenWidth - 16, height: XDSize.unitWidth), color: XDColor.itemLine)
        contentView.addSubview(topLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class func height(for object: Any!, at indexPath: IndexPath!, tableView: UITableView!) -> CGFloat {
        return 96
    }
    
    override func shouldUpdate(with object: Any!) -> Bool {
        if super.shouldUpdate(with: object), let object = object as? CourseOutlineItem {
            chapterTitleLabel.text = object.model.chapterName
            topLine.isHidden = object.index == 0
        }
        return true
    }
}
