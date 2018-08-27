//
//  CourseDetailEvaluationBoardViewController.swift
//  xxd
//
//  Created by remy on 2018/1/19.
//  Copyright © 2018年 com.smartstudy. All rights reserved.
//

import pop

private let kEvaluationBoardViewWidth: CGFloat = 295
private let kEvaluationBoardViewHeight: CGFloat = 304

class CourseDetailEvaluationBoardViewController: SSViewController, EvaluationBoardViewDelegate {
    
    private var boardView: EvaluationBoardView!
    var courseID = 0
    
    override func needNavigationBar() -> Bool {
        return false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // growingIO造成dismiss后控制器不第一时间销毁,如果二次吊起,动画会冲突
        if boardView != nil {
            boardView.pop_removeAllAnimations()
            boardView.removeFromSuperview()
            boardView = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoresizesForKeyboard = true
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = false
        
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundViewPressed(gestureRecognizer:))))
        view.addSubview(backgroundView)
        
        boardView = EvaluationBoardView(frame: CGRect(x: (view.width - 295) * 0.5, y: 0, width: 295, height: 304))
        boardView.centerY = view.height * 0.5 - 20
        boardView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin]
        boardView.delegate = self
        boardView.isHidden = true
        view.addSubview(boardView)
        
        boardView.layer.pop_removeAnimation(forKey: "scaleAnimation")
        if let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY) {
            scaleAnimation.fromValue = CGSize(width: 0, height: 0)
            scaleAnimation.velocity = CGSize(width: 5, height: 5)
            scaleAnimation.toValue = CGSize(width: 1, height: 1)
            scaleAnimation.springBounciness = 10
            scaleAnimation.removedOnCompletion = true
            scaleAnimation.completionBlock = {
                [weak self] (anim, finished) in
                self?.view.isUserInteractionEnabled = true
            }
            boardView.layer.pop_add(scaleAnimation, forKey: "scaleAnimation")
            boardView.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func dismissWithAnimation() {
        view.isUserInteractionEnabled = false
        if let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY) {
            scaleAnimation.fromValue = CGSize(width: 1, height: 1)
            scaleAnimation.toValue = CGSize(width: 0, height: 0)
            scaleAnimation.duration = 0.25
            scaleAnimation.removedOnCompletion = true
            scaleAnimation.completionBlock = {
                [weak self] (anim, finished) in
                self?.dismiss(animated: false, completion: nil)
                self?.boardView.removeFromSuperview()
            }
            boardView.layer.pop_add(scaleAnimation, forKey: "scaleAnimation")
        }
    }
    
    //MARK:- Notification
    @objc private func keyboardWillShow(notification: Notification) {
        if let rect = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? CGRect {
            let submitBounds = boardView.convert(boardView.submitButton.frame, to: nil)
            if submitBounds.minY - submitBounds.maxY - 20 < 0 {
                boardView.bottom = rect.minY + 4
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        boardView.centerY = view.height * 0.5 - 20
    }
    
    //MARK:- Action
    @objc func backgroundViewPressed(gestureRecognizer: UIGestureRecognizer) {
        if boardView.isFirstResponder {
            view.endEditing(true)
        } else {
            dismissWithAnimation()
        }
    }
    
    //MARK:- EvaluationBoardViewDelegate
    func evaluationBoardViewDidSubmitPressed(rate: Int, content: String) {
        let urlStr = String(format: XD_API_COURSE_SUBMIT_EVALUATION, courseID)
        XDPopView.loading()
        SSNetworkManager.shared().post(urlStr, parameters: ["rate":rate,"comment":content], success: { [weak self] (task, responseObject) in
            if let strongSelf = self {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: XD_NOTIFY_EVALUATE_COURSE_SUC), object: nil, userInfo: [QueryKey.CourseID:strongSelf.courseID])
                strongSelf.dismissWithAnimation()
            }
            XDPopView.toast("course_submit_evaluation_success".localized, self?.view)
        }) { (task, error) in
            XDPopView.toast(error.localizedDescription)
        }
    }
}
