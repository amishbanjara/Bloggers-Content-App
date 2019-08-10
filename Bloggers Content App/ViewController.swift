//
//  ViewController.swift
//  Bloggers Content App
//
//  Created by IMCS2 on 8/6/19.
//  Copyright © 2019 patelashish797. All rights reserved.
//

import UIKit
import WebKit
import Network

class ViewController: UIViewController {
    let monitor = NWPathMonitor()
    var blogName:String = ""
    var blogUrl: String = ""
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL(string: blogUrl)
        let urlReq = URLRequest(url: url! as URL)
        webView.load(urlReq)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("We're connected!")
            } else {
                print("No connection.")
                DispatchQueue.main.async {
                    self.webView.loadHTMLString("<html><body><h1>Cannot Display the Url \(url!)! you need internet connection</h1></body></html>", baseURL: nil)
                }
            }
            print(path.isExpensive)
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    override func viewWillAppear(_ animated: Bool) {
        titleLabel.text = blogName
    }
}
