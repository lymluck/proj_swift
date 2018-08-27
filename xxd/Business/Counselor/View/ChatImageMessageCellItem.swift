//
//  ChatImageMessageCellItem.swift
//  counselor_t
//
//  Created by chenyusen on 2018/1/10.
//  Copyright © 2018年 TechSen. All rights reserved.
//

import UIKit
import SSPhotoBrowser
import ZMJImageEditor
import ZXingObjC

class ChatImageCellLayout: ChatMessageCellLayout {
    var imageFrame: CGRect = CGRect.zero
}



/// image message cell item
class ChatImageMessageCellItem: ChatMessageCellItem {
    var progress: Int = 0
    var image: UIImage?
    
    override var cellClass: UITableViewCell.Type? {
        return ChatImageMessageCell.self
    }
    
    
    public init() {
        super.init()
        handleProgress = { [weak self] (progress) in
            
            if let currentCell = self?.currentCell as? ChatImageMessageCell {
                self?.progress = progress
                currentCell.updateCell(self)
            }
        }
    }
    
    override var model: Any? {
        didSet {
            if let message = (model as? Message), let _ = message.content as? ImageMessage {
                if message.sentStatus == .SentStatus_SENT { progress = 100 }
            }
        }
    }
    
    
    override func updateLayout() {
        if layout == nil {
            let layout = ChatImageCellLayout()
            self.layout = layout
            /// 计算图片的frame
            if let image = ((model as? Message)?.content as? ImageMessage)?.thumbnailImage {
                let width = bubbleMaxImageWidth
                let height = width * image.size.height / image.size.width
                layout.bubbleFrame = calBubbleFrame(withContentSize: CGSize(width: width, height: height), autoAdjust: false, isSelf: isSelf)
                layout.imageFrame = CGRect(origin: CGPoint.zero, size: layout.bubbleFrame.size)
                layout.cellHeight = layout.bubbleFrame.maxY + messageCellBottomMargin
            }
            super.updateLayout()
        }
    }
    
    override var cellHeight: CGFloat {
        return layout?.cellHeight ?? 0
    }
}

/// image message cell
class ChatImageMessageCell: ChatMessageCell {
    var imgView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
     
    }
    
    override func updateCell(_ cellItem: TableCellItemProtocol?) {
        super.updateCell(cellItem)
        if let cellItem = cellItem as? ChatImageMessageCellItem,
            let layout = cellItem.layout as? ChatImageCellLayout,
            let contentMessage = (cellItem.model as? Message)?.content as? ImageMessage {
            imgView.image = contentMessage.thumbnailImage
            imgView.frame = layout.imageFrame
            bubbleView.content = imgView
//            bubbleView.progress = cellItem.progress
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bubbleViewTapped(_ gr: UITapGestureRecognizer) {
        if let cellItem = cellItem as? ChatImageMessageCellItem, let contentMessage = (cellItem.model as? Message)?.content as? ImageMessage {
            let imageUrl = contentMessage.imageUrl?.absoluteString
            if let imageUrl = imageUrl {
                let photoBrower = SSPhotoBrowser(photoURLs: [imageUrl],
                                                 placeholderImages: [imgView.image!],
                                                 animatedFrom: imgView)
                photoBrower?.displayDoneButton = false
                photoBrower?.displayActionButton = false
                photoBrower?.dismissOnTouch = true
                photoBrower?.forceHideStatusBar = true
                photoBrower?.longPressedAction = { [weak self] image in
                    guard let aImage = image else { return }
                    self?.showImageHandleSheet(image: aImage, needEdit: true)
                }
    //            photoBrower?.scaleImage = imgView.image
                self.viewController?.present(photoBrower!, animated: true)
            }
        }
    }
    
    override func bubbleViewDidLongPressed() {
        if let cellItem = cellItem as? ChatImageMessageCellItem, let message = cellItem.model as? Message {
            var buttonTypes: [ChatPopView.ButtonType] = []
            if cellItem.isSelf {
                
                if !CounselorIM.shared.isMessageExpire(message) { // 只有没超时的消息才能被撤回
                    buttonTypes.append(.recall)
                }
            }
            buttonTypes.append(contentsOf: [.transpond, .edit])
            if !buttonTypes.isEmpty {
                ChatPopView.shared.setButtonTypes(buttonTypes)
                ChatPopView.shared.delegate = self
                ChatPopView.shared.show(referTo: bubbleView)
                bubbleView.showCover = true
            }
        }
    }
    
    func showImageHandleSheet(image: UIImage, needEdit: Bool = false) {
        let sheetActionAlertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        let sendAction = UIAlertAction(title: "发送给好友", style: .default) {[weak self] (action) in
            SSLog("发送给好友")
            guard let sSelf = self else { return }
            if let message = sSelf.cellItem?.model as? Message, let content = message.content as? ImageMessage {
                content.originalImage = image
                UIApplication.topVC()?.presentModalTranslucentViewController(TranspondViewController(query: [UserInfo.Message: message]), animated: false, completion: nil)
            
            }
            //            editor.presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
        let saveAction = UIAlertAction(title: "保存图片", style: .default) { (action) in
            SSLog("保存图片")
            XDPopView.loading()
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
//            UIApplication.shared.topViewController()?.dismiss(animated: true, completion: nil)
        }
        sheetActionAlertVC.addAction(sendAction)
        sheetActionAlertVC.addAction(saveAction)
        if needEdit {
            let editAction = UIAlertAction(title: "编辑", style: .default) { [weak self] (action) in
                SSLog("编辑")
                self?.showEdit()
            }
            sheetActionAlertVC.addAction(editAction)
        }
        
        // 识别是否有二维码
        let source = ZXCGImageLuminanceSource(cgImage: image.cgImage!)
        let bitmap = ZXBinaryBitmap(binarizer: ZXHybridBinarizer(source: source))
        let hints = ZXDecodeHints.hints() as! ZXDecodeHints
        let reader = ZXMultiFormatReader.reader() as! ZXMultiFormatReader
        
        do {
           let result = try reader.decode(bitmap, hints: hints)
            
            SSLog("识别出了二维码, 内容是\(result.text ?? "")")
            let qrAction = UIAlertAction(title: "识别二维码", style: .default) { [weak self] (action) in
                SSLog("识别二维码")
                XDPopView.toast(result.text)
            }
            sheetActionAlertVC.addAction(qrAction)
        } catch {
            
        }

        sheetActionAlertVC.addAction(cancelAction)
        
        UIApplication.topVC()?.presentVC(sheetActionAlertVC)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            XDPopView.toast("保存图片成功")
        } else {
            XDPopView.toast("保存图片失败")
        }
    }
    
    func showEdit() {
        if let cellItem = cellItem as? ChatImageMessageCellItem,
            let contentMessage = (cellItem.model as? Message)?.content as? ImageMessage,
            let imageUrl = contentMessage.imageUrl {
            if let image = SDImageCache.shared().imageFromCache(forKey: SDWebImageManager.shared().cacheKey(for: imageUrl)) {
                let imageEditor = WBGImageEditor(image: image, delegate: self, dataSource: self)
                UIApplication.topVC()?.present(imageEditor!, animated: true, completion: nil)
            } else {
                XDPopView.loading()
                SDWebImageDownloader.shared().downloadImage(with: imageUrl, options: [.useNSURLCache], progress: nil, completed: { (image, _, _, _) in
                    XDPopView.hide()

                    let imageEditor = WBGImageEditor(image: image, delegate: self, dataSource: self)
                    UIApplication.topVC()?.present(imageEditor!, animated: true, completion: nil)
                })
            }
            
        }
    }
}

extension ChatImageMessageCell: ChatPopViewDelegate {
    func chatPopView(didPressed buttonType: ChatPopView.ButtonType) {
        switch buttonType {
        case .transpond:
            if let message = cellItem?.model as? Message {
                UIApplication.shared.topViewController()?.presentModal(TranspondViewController(query: [UserInfo.Message: message]))
            }
        case .recall:
            if let message = cellItem?.model as? Message {
                CounselorIM.shared.recallMessage(message)
            }
        case .delete:
            if let message = cellItem?.model as? Message {
                CounselorIM.shared.deleteMessages([message.messageId])
                NotificationCenter.default.post(name: .IMMessageDeleted,
                                                object: nil,
                                                userInfo: [UserInfo.MessageId: message.messageId])
            }
        case .edit:
            showEdit()
        default:
            SSLog("未实现功能")
        }
    }
    
    
}

extension ChatImageMessageCell: WBGImageEditorDelegate {
    func imageEditorDidCancel(_ editor: WBGImageEditor!) {
        editor.dismiss(animated: true, completion: nil)
    }

    func imageEditor(_ editor: WBGImageEditor!, didFinishEdittingWith image: UIImage!) {
//        editor.dismiss(animated: true, completion: nil)
        showImageHandleSheet(image: image)
    }
}

extension ChatImageMessageCell: WBGImageEditorDataSource {
    func imageItemsEditor(_ editor: WBGImageEditor!) -> [WBGMoreKeyboardItem]! {
        return []
    }

    func imageEditorCompoment() -> WBGImageEditorComponent {
        return WBGImageEditorComponent.wholeComponent
    }
}


