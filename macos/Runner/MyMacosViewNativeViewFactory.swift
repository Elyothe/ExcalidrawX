//
//  MyMacosViewNativeViewFactory 2.swift
//  Runner
//
//  Created by Vincenot Eliot on 20/05/2026.
//


import Cocoa
import FlutterMacOS
import WebKit

class MyMacosViewNativeViewFactory: NSObject, FlutterPlatformViewFactory {

    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func createArgsCodec() -> (FlutterMessageCodec & NSObjectProtocol)? {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withViewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> NSView {

        let webView = WKWebView(frame: .zero)

        if let args = args as? [String: Any],
           let urlString = args["url"] as? String,
           let url = URL(string: urlString) {

            let request = URLRequest(url: url)
            webView.load(request)
        }

        return webView
    }
}
