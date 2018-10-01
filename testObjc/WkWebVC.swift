//
//  WkWebVC.swift
//  TestApp
//
//  Created by DerekYang on 2018/9/28.
//  Copyright © 2018年 DKY. All rights reserved.
//


import UIKit
import WebKit
import SafariServices

struct ST_URL_RESULT: Codable
{
    let name: String?
    let url: String?
}

class WkWebVC: UIViewController {
    
    let appVer = "1.0"
    
    var urlStr = "" {
        didSet {
            if let _url = URL(string: self.urlStr) {
                let request = URLRequest(url: _url)//, cachePolicy: .reloadRevalidatingCacheData)
                DispatchQueue.main.async {
                    self.m_webView?.load(request)
                }
            }
        }
    }
    
    var m_flag = false
    var m_topConstraint: NSLayoutConstraint? = nil
    
    var m_webView: WKWebView? = nil
    var m_indicator: UIActivityIndicatorView? = nil
    let m_configuration = WKWebViewConfiguration()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupWebView()
        self.setupIndicator()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupIndicator()
    {
        if(nil == self.m_indicator) {
            self.m_indicator = UIActivityIndicatorView(style: .whiteLarge)
            if let indicator =  self.m_indicator {
                indicator.color = UIColor.gray
                view.addSubview(indicator)
                indicator.translatesAutoresizingMaskIntoConstraints = false
                indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
                indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            }
        }
    }
    
    func clearCache()
    {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records, completionHandler: {
                //                print("clear")
            })
            //            for record in records {
            //                if record.displayName.contains("facebook") {
            //                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {
            //                        print("Deleted: " + record.displayName);
            //                    })
            //                }
            //            }
        }
    }
    
    func openFastLink(urls: [String])
    {
        let q = DispatchQueue.global()
        for urlStr in urls {
            q.async {
                
                if let url = URL(string: urlStr) {
                    
                    let urlRequest = URLRequest(url: url)
                    
                    // set up the session
                    let config = URLSessionConfiguration.default
                    let session = URLSession(configuration: config)
                    
                    // make the request
                    let task = session.dataTask(with: urlRequest) {
                        (data, response, error) in
                        
                        if(self.m_flag) {
                            return
                        }
                        
                        // check for any errors
                        guard error == nil else {
                            print(error!)
                            return
                        }
                        // make sure we got data
                        guard let _ = data else {
                            print("Error: did not receive data")
                            return
                        }
                        // parse the result as JSON, since that's what the API provides
                        
                        self.m_flag = true
                        DispatchQueue.main.async {
                            // 程式碼片段 ...
                            self.m_webView?.load(urlRequest)
                        }
                    }
                    task.resume()
                }
            }
        }
    }
}

extension WkWebVC: WKNavigationDelegate, WKUIDelegate
{
    func setupWebView() {
        if(nil != self.m_webView) {
            return
        }
        
        m_configuration.allowsInlineMediaPlayback = true
        m_configuration.userContentController.add(self, name: "clearCache")
        
        // js代码片段
        //        let jsStr = "let deviceInfo = ''"
        
        // 根据JS字符串初始化WKUserScript对象
        //        let userScript = WKUserScript(source: jsStr, injectionTime:.atDocumentEnd, forMainFrameOnly: true)
        //        let userContentController = WKUserContentController()
        //        userContentController.addUserScript(userScript)
        
        // 根据生成的WKUserScript对象，初始化WKWebViewConfiguration
        //        configuration.userContentController = userContentController
        
        self.m_webView = WKWebView(frame: CGRect.zero, configuration: m_configuration)
        if let webView = self.m_webView {
        
            let arrVer = appVer.components(separatedBy: ".")
            let mainVer = Int(arrVer[0]) ?? 1
            if(mainVer >= 2) {
                //      "Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366"
                let deviceModel = UIDevice.current.model
                let systemName = UIDevice.current.systemName
                let sysVersion = UIDevice.current.systemVersion
                let modelName = UIDevice.current.modelName
                webView.customUserAgent =  "Mozilla/5.0 (\(deviceModel);\(systemName) \(sysVersion)) AppleWebKit (KHTML, like Gecko) Mobile AppVer:\(appVer) model:\(modelName)"
            }
            
            
            webView.allowsBackForwardNavigationGestures = true
            webView.navigationDelegate = self
            
            webView.uiDelegate = self
            
            self.view.addSubview(webView)
            webView.translatesAutoresizingMaskIntoConstraints = false
            if #available(iOS 11.0, *) {
                webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
                webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
                webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
                webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            } else {
                // Fallback on earlier versions
                self.edgesForExtendedLayout = []
                m_topConstraint = webView.topAnchor.constraint(equalTo: view.topAnchor)
                // webView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                m_topConstraint?.isActive = true
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            }
        }
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //        print("didStartProvisionalNavigation")
        
        m_indicator?.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        //        print("didCommit")
        
        m_indicator?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //        print("didFinish")
        
        m_indicator?.stopAnimating()
        
        //        webView.evaluateJavaScript("navigator.userAgent")  { (result, error) in
        //            if let _result = result as? String {
        //                print(_result)
        //            }
        //        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //        print("didFail, error: \(error.localizedDescription)")
        
        m_indicator?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        //        print("didFailProvisionalNavigation, error: \(error.localizedDescription)")
        
        m_indicator?.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        //        print("didReceiveServerRedirectForProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let url = navigationResponse.response.url {
            //            print("decidePolicyFor navigationResponse response url: \(url.absoluteString)")
            
            if url.absoluteString.hasSuffix("close.html") {
                m_webView?.isHidden = true
            }
        }
        
        decisionHandler(WKNavigationResponsePolicy.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        let arrVer = appVer.components(separatedBy: ".")
        let mainVer = Int(arrVer[0]) ?? 1
        if let url = navigationAction.request.url {
            if(1==mainVer) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                //                let safariVC = SFSafariViewController(url: url)
                //                safariVC.delegate = self
                //                self.present(_: safariVC, animated: true, completion: nil)
                let vc = MyTestVC()
                    
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
        return nil
    }
    
}


extension WkWebVC: WKScriptMessageHandler
{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        print(message.name)
        if message.name == "clearCache" {
            //            if let dic = message.body as? NSDictionary {
            //                print(dic["className"] as? String ?? "")
            //                print(dic["functionName"] as? String ?? "")
            //            }
            self.clearCache()
        }
    }
}

extension WkWebVC: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        //controller.dismiss(animated: false, completion: nil)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //controller.dismiss(animated: false, completion: nil)
    }
}

extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
}



