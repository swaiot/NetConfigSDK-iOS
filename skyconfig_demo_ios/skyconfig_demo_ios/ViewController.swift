//
//  ViewController.swift
//  skyconfig_demo
//
//  Created by marklei on 2020/1/19.
//  Copyright © 2020 Skyworth. All rights reserved.
//

import UIKit
import rustlib
import Connectivity

class ViewController: UIViewController, SkyConfigCallback {
    func require_ssid_list() {
        NSLog("require_ssid_list")
        DispatchQueue.main.async {
            self.go_wifi_btn.isEnabled = true
        }
    }
    
    func require_connect_wifi(ssid: String, password: String) {
        print("require_connect_wifi ssid: \(ssid) password: \(password)")
        require_ssid = ssid
        DispatchQueue.main.async {
            self.ssid_label.text = ssid
            self.password_label.text = password
            self.go_wifi_btn.isEnabled = true
        }
    }
    
    func require_network_info(is_wifi_or_active: Bool) {
        NSLog("require_network_info: %d", is_wifi_or_active)
        SkyConfigContract.on_network_change(is_connect: is_connect, ssid: current_ssid)
    }
    
    func on_config_progress(progress: Int8, total: Int8) {
        NSLog("on_config_progress progress: %d, total: %d", progress, total)
        DispatchQueue.main.async() {
            self.progress_label.text = String(format:"%d / %d", arguments:[progress, total])
        }
        
    }
    
    func on_config_ok(device: String) {
        print("on_config_ok device: \(device)")
        DispatchQueue.main.async() {
            self.result_label.text = "OK, device: " + device
            self.start_btn.isEnabled = true
            self.stop_btn.isEnabled = false
            self.go_wifi_btn.isEnabled = false
            self.ssid_label.text = ""
            self.password_label.text = ""
        }
        
    }
    
    func on_config_fail(code: Int, msg: String) {
        NSLog("on_config_fail code: %d, msg: %s", code, msg)
        DispatchQueue.main.async() {
            self.result_label.text = String(format: "FAIL, code: %d, msg: %s" , arguments:[code, msg])
            self.start_btn.isEnabled = true
            self.stop_btn.isEnabled = false
            self.go_wifi_btn.isEnabled = false
            self.ssid_label.text = ""
            self.password_label.text = ""
        }
    }
    fileprivate let connectivity: Connectivity = Connectivity()
    
    @IBOutlet weak var stop_btn: UIButton!
    @IBOutlet weak var start_btn: UIButton!
    @IBOutlet weak var router_ssid: UITextField!
    @IBOutlet weak var router_password: UITextField!
    @IBOutlet weak var current_ssid_label: UILabel!
    @IBOutlet weak var progress_label: UILabel!
    @IBOutlet weak var ssid_label: UILabel!
    @IBOutlet weak var password_label: UILabel!
    @IBOutlet weak var go_wifi_btn: UIButton!
    @IBOutlet weak var result_label: UILabel!
    
    var is_connect: Bool = false
    var current_ssid: String = ""
    var require_ssid: String = ""
    
    @IBAction func on_stop_config(_ sender: UIButton) {
        NSLog("stop_config")
        let ret = SkyConfigContract.stop_config()
        NSLog("stop_config ret: %d", ret)
        start_btn.isEnabled = true
        stop_btn.isEnabled = false
        go_wifi_btn.isEnabled = false
    }
    @IBAction func on_start_config(_ sender: UIButton) {
        NSLog("on_start_config")
        let router_ssid =  self.router_ssid.text ?? ""
        let router_password = self.router_password.text ?? ""
        Thread.detachNewThread {
            print("on_start_config:\(Thread.current)")
            let ret = SkyConfigContract.start_config(router_ssid: router_ssid,
                                        router_password: router_password, device_ap: "")
            NSLog("start_config ret: %d", ret)
        }
        stop_btn.isEnabled = true
        start_btn.isEnabled = false
        /*** 由于iOS不能获取周边的Wi-Fi热点和自动连接指定的热点,所以只能让用户手动连接硬件热点。
         以下是常用硬件热点形式
         ***/
        require_connect_wifi(ssid: "SKYLINKxxMxxxx", password: "12345678")
        //以下是旧款硬件热点形式，数量较少
        //require_connect_wifi(ssid: "skynj-xxxxxxxxxxxx", password: "xxxxxxxxxxxx") //密码为热点后12位
        result_label.text = ""
        progress_label.text = ""
    }
    @IBAction func go_wifi_setting(_ sender: Any) {
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!)
    }
     
    func init_connectivity() {

        let connectivityChanged: (Connectivity) -> Void = { [weak self] connectivity in
             self?.updateConnectionStatus(connectivity.status)
        }
        connectivity.connectivityURLs = [URL(string: "https://www.apple.com/library/test/success.html")!]
        connectivity.whenConnected = connectivityChanged
        connectivity.whenDisconnected = connectivityChanged
        connectivity.isPollingEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        init_connectivity()
        current_ssid_label.text = NetworkUtils.getWifiSsid()
        let ret = SkyConfigContract.do_init(
                      uid: "" ,//填入酷开用户id，对于open id,
                      ak: "" ,// 用户access token,
                      app_key: "" , //分配的应用id,
                      app_secret: "" ,//分配的应用secret,
                      config_callback: self)
        NSLog("do_init: ret: %d", ret)
        connectivity.startNotifier()
//        updateConnectionStatus(connectivity.status)
    }
    
    func updateConnectionStatus(_ status: ConnectivityStatus) {
        print("updateConnectionStatus : \(status)")
        var is_connect = true
        switch status {
            case .connected:
                break;
            case .connectedViaWiFi:
                break;
            case .connectedViaWiFiWithoutInternet:
                break;
            case .connectedViaCellular:
                break;
            case .connectedViaCellularWithoutInternet:
                break;
            case .notConnected:
                is_connect = false
                break
            case .determining:
                break
        }
        self.is_connect = is_connect
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1) ) {
            self.checkSsid()
        }
        
    }
    func checkSsid() {
        let ssid = NetworkUtils.getWifiSsid() ?? ""
        if (current_ssid != ssid) {
            current_ssid = ssid
            if (current_ssid == require_ssid) {
                go_wifi_btn.isEnabled = false
                ssid_label.text = ""
                password_label.text = ""
            }
            current_ssid_label.text = current_ssid
            SkyConfigContract.on_network_change(is_connect: is_connect, ssid: current_ssid)
        }
        
    }
}

