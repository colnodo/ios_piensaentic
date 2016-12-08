import UIKit
import MFSideMenu

class HomeViewController: MFSideMenuContainerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.responds(to: #selector(getter: UIViewController.edgesForExtendedLayout)){
            self.edgesForExtendedLayout = UIRectEdge.all
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.initialSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Initial Setup
    func initialSetup() -> (){
        let mainConfigurator = MainConfigurator.sharedConfiguration
        let content = mainConfigurator.chapter(index: 0)
        print(content as Any)
        let homeStoryboard = UIStoryboard.init(name: "Menu", bundle: Bundle.main)
        let propertiesStoryboard = UIStoryboard.init(name: "Chapters", bundle: Bundle.main)
        let navigationController = propertiesStoryboard.instantiateViewController(withIdentifier: StoryboardIdentifier.chapterMain)
        let rightSideMenuViewController = homeStoryboard.instantiateViewController(withIdentifier: StoryboardIdentifier.rightMenu)
        
        var arrayContent:[String] = []
        for i in 0 ..< mainConfigurator.countKeysByPrefix(content!, prefix: "page") {
            arrayContent.append(["page",String(i)].flatMap{$0}.joined(separator: ""))
        }
        
        (navigationController as! CarrouselChapterViewController).imagesArray = arrayContent
        
        self.rightMenuViewController = rightSideMenuViewController
        self.centerViewController = navigationController
    }
    
    //MARK: Controller Actions
    @IBAction func leftSideMenuButtonPressed(sender:Any) -> (){
        self.menuContainerViewController.toggleLeftSideMenuCompletion {
        }
    }
    
    @IBAction func rightSideMenuButtonPressed(sender:Any) -> () {
        self.menuContainerViewController.toggleRightSideMenuCompletion { 
        }
    }
}