/**
 Copyright (c) 2016 Rory Hool
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 **/

import Foundation

class CreditsViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Credits"
        
        let text = NSMutableAttributedString()
        text.append(getAppLink())
        text.append(getIconCredit())
        text.append(getMP4ParseCredit())
        
        textView.attributedText = text
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidAppear(_ animated:Bool) {
        super.viewDidAppear(animated)
        
        if let tracker = GAI.sharedInstance().defaultTracker {
            tracker.set(kGAIScreenName, value: "CreditsViewController")
            let builder: NSObject = GAIDictionaryBuilder.createScreenView().build()
            tracker.send(builder as! [AnyHashable: Any])
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func getAppLink() -> NSAttributedString {
        let credit = NSMutableAttributedString(string: "Complete app source code available on Github\n\n")
        credit.addAttribute(NSLinkAttributeName, value:"http://github.com/hoolrory/VideoInfoViewer-iOS", range:NSMakeRange(38, 6))
        return credit
    }
    
    func getIconCredit() -> NSAttributedString {
        let credit = NSMutableAttributedString(string: "Icon provided by Simeon K.\n\n")
        credit.addAttribute(NSLinkAttributeName, value:"http://dribbble.com/sok", range:NSMakeRange(17, 9))
        return credit
    }
    
    func getMP4ParseCredit() -> NSAttributedString {
        let credit = NSMutableAttributedString(string: "This software contains MP4Parse (Copyright Jean-David Gadina - XS-Labs) licensed under the Boost License.\n\nBoost Software License - Version 1.0 - August 17th, 2003\n\nPermission is hereby granted, free of charge, to any person or organization obtaining a copy of the software and accompanying documentation covered by this license (the \"Software\") to use, reproduce, display, distribute, execute, and transmit the Software, and to prepare derivative works of the Software, and to permit third-parties to whom the Software is furnished to do so, all subject to the following:  \n\nThe copyright notices in the Software and this entire statement, including the above license grant, this restriction and the following disclaimer, must be included in all copies of the Software, in whole or in part, and all derivative works of the Software, unless such copies or derivative works are solely in the form of machine-executable object code generated by a source language processor.  \n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.")
        
        credit.addAttribute(NSLinkAttributeName, value:"https://github.com/macmade/MP4Parse", range:NSMakeRange(23, 8))
        return credit
    }
}
