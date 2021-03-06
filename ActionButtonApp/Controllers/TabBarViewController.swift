
import UIKit
//import DynamicButton
import ActionButton

struct MainViewController {
    let storyboardName: String
    let imageName: String
}

class TabBarViewController: UIViewController {
    
    let viewControllers: [UIViewController]
    private let imageViews: [UIImageView]
    private var tabBarVisibleConstant = CGFloat(0)
    private var tabBarHiddenConstant: CGFloat!
    
    var tabBarActionButton: ActionButton!
    
    @IBOutlet var tabBar: UIView!
    @IBOutlet var tabBarSeparator: UIView!
    @IBOutlet var tabBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tabBarBottomConstraint: NSLayoutConstraint!
    
    var selectedViewControllerIndex: Int = 0 {
        didSet {
            imageViews[oldValue].tintColor = nil
            imageViews[selectedViewControllerIndex].tintColor = .tabBarSelectedItemColor()
            switchToViewController(viewControllers[selectedViewControllerIndex])
        }
    }
    
    var selectedViewController: UIViewController!
    
    required init?(coder aDecoder: NSCoder) {
        
        var vcs = [UIViewController]()
        var ivs = [UIImageView]()
        let bundle = NSBundle.mainBundle()
        for (i, mvc) in TabBarConstants.mainViewControllers.enumerate() {
            
            vcs.append(UIStoryboard(name: mvc.storyboardName, bundle: bundle).instantiateInitialViewController()!)
            
            let iv = UIImageView(frame: .zero)
            iv.contentMode = .Center
            iv.tag = i
            iv.image = UIImage(named: mvc.imageName)?.imageWithRenderingMode(.AlwaysTemplate)
            iv.translatesAutoresizingMaskIntoConstraints = false
            ivs.append(iv)
        }
        
        viewControllers = vcs
        imageViews = ivs
        
        super.init(coder: aDecoder)
    }
    
    //MARK: - Setup
    
    func setup() {
        addSubviews()
        setupConstraints()
        addGestureRecognizers()
        
        //tabBar.tintColor = MHImageTabBarConstants.tabBarUnselectedItemColor
        tabBar.tintColor = .tabBarUnselectedItemColor()
        //tabBar.backgroundColor = MHImageTabBarConstants.tabBarBackgroundColor
        tabBar.backgroundColor = .tabBarBackgroundColor()
        //tabBarSeparator.backgroundColor = MHImageTabBarConstants.tabBarSeparatorColor
        tabBarSeparator.backgroundColor = .tabBarSeparatorColor()
        tabBar.tintAdjustmentMode = .Normal
        
        
        tabBarHiddenConstant = tabBarHeightConstraint.constant
    }
    
    func addSubviews() {
        for iv in imageViews {
            tabBar.addSubview(iv)
        }
    }
    
    func setupConstraints() {
        setupImageViewsConstraints()
    }
    
    func setupImageViewsConstraints() {
        if TabBarConstants.RTL {
            tabBar.alignViews(imageViews, firstAttribute: .Right, secondAttribute: .Left)
        } else {
            tabBar.alignViews(imageViews, firstAttribute: .Left, secondAttribute: .Right)
        }
        
        let firstIV = imageViews.first!
        
        tabBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[firstIV]|", options: [], metrics: nil, views: ["firstIV":firstIV]))
        
        for i in 1 ..< imageViews.count {
            let iv = imageViews[i]
            tabBar.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[iv]|", options: [], metrics: nil, views: ["iv":iv]))
            tabBar.addConstraint(NSLayoutConstraint(item: iv, attribute: .Width, relatedBy: .Equal, toItem: firstIV, attribute: .Width, multiplier: 1, constant: 0))
        }
    }
    
    func addGestureRecognizers() {
        for iv in imageViews {
            iv.userInteractionEnabled = true
            iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("gestureRecognizerTapped:")))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setup()
        
        // Do any additional setup after loading the view.
        
        let prayerActionButton = UIButton(type: UIButtonType.Custom)
        
        prayerActionButton.frame = CGRectMake(94.0, 0.0, 131.0, self.tabBar.bounds.size.height)
        
        prayerActionButton.setImage(UIImage(named: "ButtonCamera.png"), forState: UIControlState.Normal)
        prayerActionButton.setImage(UIImage(named: "ButtonCameraSelected.png"), forState: UIControlState.Highlighted)
        prayerActionButton.addTarget(self, action: Selector("prayerButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.tabBar.addSubview(prayerActionButton)
        
        
        let oneImage = UIImage(named: "one.png")!
        let twoImage = UIImage(named: "two.png")!
        
        let oneButton = ActionButtonItem(title: "Action Item 1", image: oneImage)
        oneButton.action = { item in print("Action Item 1...") }
        
        let twoButton = ActionButtonItem(title: "Action Item 2", image: twoImage)
        twoButton.action = { item in print("Action Item 2...") }
        
        //tabBarActionButton.addTarget(self, action: Selector("prayerButtonAction:"), forControlEvents: UIControlEvents.TouchUpInside)
        
        tabBarActionButton = ActionButton(attachedToView: self.view, items: [oneButton, twoButton])
        tabBarActionButton.action = { button in button.toggleMenu() }
        tabBarActionButton.setTitle("+", forState: .Normal)

        tabBarActionButton.backgroundColor = UIColor(red: 238.0/255.0, green: 130.0/255.0, blue: 34.0/255.0, alpha:1.0)
        
        
        selectedViewControllerIndex = 0
    }
    
    
    // MARK:- ()
    
    ///////////////////////////////
    
    
    func prayerButtonAction(sender: AnyObject) {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        

        let addPrayerAction = UIAlertAction(title: NSLocalizedString("Add Prayer", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
            self.navigationController!.pushViewController(AddPrayerViewController(), animated: true)
        })
        let logOutAction = UIAlertAction(title: NSLocalizedString("Log Out", comment: ""), style: UIAlertActionStyle.Default, handler: { _ in
            // Log out user and present the login view controller
            //(UIApplication.sharedApplication().delegate as! AppDelegate).logOut()
            print("Log Me Out Please")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        //actionController.addAction(myProfileAction)
        //actionController.addAction(findFriendsAction)
        actionController.addAction(addPrayerAction)
        actionController.addAction(logOutAction)
        actionController.addAction(cancelAction)
        
        self.presentViewController(actionController, animated: true, completion: nil)
    }
    
    // MARK:- UIImagePickerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    ///////////////////////
    
    //MARK: - actions
    
    func switchToViewController(toVC: UIViewController) {
        
        selectedViewController?.removeFromParentViewController()
        selectedViewController?.view.removeFromSuperview()
        selectedViewController?.didMoveToParentViewController(nil)
        
        addChildViewController(toVC)
        addChildView(toVC.view)
        toVC.didMoveToParentViewController(self)
        
        selectedViewController = toVC
    }
    
    func addChildView(aView: UIView) {
        
        aView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(aView)
        let views = ["child": aView, "tabBar": tabBar]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[child]|", options: .DirectionLeftToRight, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[child][tabBar]", options: [], metrics: nil, views: views))
        
        view.layoutIfNeeded()
    }
    
    func gestureRecognizerTapped(tgr: UITapGestureRecognizer) {
        selectedViewControllerIndex = tgr.view!.tag
    }
    
    //MARK: - tab bar hide and show
    
    func setTabBarVisible(visible: Bool, animated: Bool = true) {
        let constant = visible ? tabBarVisibleConstant : tabBarHiddenConstant
        let duration = animated ? TabBarConstants.tabBarAnimationDuration : 0
        
        UIView.animateWithDuration(duration) {
            [unowned self]
            () -> Void in
            
            self.tabBarBottomConstraint.constant = constant
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - ui view controller extension for tab bar

extension UIViewController {
    var mhTabBarViewController: TabBarViewController? {
        var vc = parentViewController
        
        while vc != nil {
            if vc is TabBarViewController {
                return vc as? TabBarViewController
            } else {
                vc = vc?.parentViewController
            }
        }
        
        return nil
    }
}
//MARK: - Helper

extension UIView {
    
    func alignViews(views: [UIView], firstAttribute: NSLayoutAttribute, secondAttribute: NSLayoutAttribute) {
        var previousView = views.first!
        addConstraint(NSLayoutConstraint(item: previousView, attribute: firstAttribute, relatedBy: .Equal, toItem: self, attribute: firstAttribute, multiplier: 1, constant: 0))
        
        var currentView: UIView
        for i in 1 ..< views.count {
            currentView = views[i]
            addConstraint(NSLayoutConstraint(item: currentView, attribute: firstAttribute, relatedBy: .Equal, toItem: previousView, attribute: secondAttribute, multiplier: 1, constant: 0))
            previousView = currentView
        }
        
        addConstraint(NSLayoutConstraint(item: previousView, attribute: secondAttribute, relatedBy: .Equal, toItem: self, attribute: secondAttribute, multiplier: 1, constant: 0))
    }
}

