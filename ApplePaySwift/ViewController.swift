//
//  ViewController.swift
//  ApplePaySwift
//
//  Created by 小城生活 on 16/3/23.
//  Copyright © 2016年 小城生活. All rights reserved.
//

import UIKit
import PassKit
class ViewController: UIViewController,PKPaymentAuthorizationViewControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 9.2, *) {
            if !PKPaymentAuthorizationViewController .canMakePayments() {
                print("该设备不支持ApplePay")
            }else if !PKPaymentAuthorizationViewController .canMakePaymentsUsingNetworks([PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay]){
                print("不支持visa卡和银联卡")
                let btnSet = PKPaymentButton(type: PKPaymentButtonType.SetUp, style: PKPaymentButtonStyle.Black)
                btnSet.frame = CGRectMake(100, 200, 80, 40)
                btnSet.addTarget(self, action: #selector(ViewController.setCard), forControlEvents: UIControlEvents.TouchUpInside)
                self.view.addSubview(btnSet)
            }else{
                let btnPay = PKPaymentButton(type: PKPaymentButtonType.Buy, style: PKPaymentButtonStyle.Black)
                btnPay.frame = CGRectMake(100, 200, 80, 40)
                btnPay.addTarget(self, action: #selector(ViewController.payAction), forControlEvents: UIControlEvents.TouchUpInside)
            
                self.view.addSubview(btnPay)
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    /**
     设置银行卡
     */
    func setCard()  {
        print("设置银行卡")
        let setCard = PKPassLibrary()
        if #available(iOS 8.3, *) {
            setCard .openPaymentSetup()
        } else {
            // Fallback on earlier versions
        }
    }
    
    /**
     付款验证
     */
    func payAction() {
        print("付款验证")
        let pkRequest = PKPaymentRequest()
        /**
         *  设置商家id
         */
        pkRequest.merchantIdentifier = "merchant.xiaochengshenghuo.www"
        pkRequest.countryCode = "CN"
        pkRequest.currencyCode = "CNY"
        if #available(iOS 9.2, *) {
            pkRequest.supportedNetworks = [PKPaymentNetworkVisa,PKPaymentNetworkChinaUnionPay]
        } else {
            pkRequest.supportedNetworks = [PKPaymentNetworkVisa,PKPaymentNetworkMasterCard]
        }
        pkRequest.merchantCapabilities = [.Capability3DS, .CapabilityEMV]
        
        /**
         设置商品价格
         */
        /// 第一组商品
        let price1 = NSDecimalNumber(float: 0.01)
        let item1 = PKPaymentSummaryItem(label: "鸡蛋一枚", amount: price1)
        
        /**
         第二组商品
         */
        let price2 = NSDecimalNumber(float: 0.02)
        let item2 = PKPaymentSummaryItem(label: "加湿器一个", amount: price2)
        
        /**
         最后要显示总价
         */
        let priceAll = NSDecimalNumber(float:price2.floatValue + price1.floatValue)
        let itemAll = PKPaymentSummaryItem(label: "文哥财务中心", amount: priceAll)
        
        pkRequest.paymentSummaryItems = [item1,item2,itemAll]
        
        
        /**
         创建授权控制器
         */
        let payControl = PKPaymentAuthorizationViewController(paymentRequest: pkRequest)
        payControl.delegate = self
        self.presentViewController(payControl, animated: true, completion: nil)
        
        
        
        
    }
    /**
     代理方法
     */
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
        print(payment.token)
        var isSceess = false
        
        dispatch_after(dispatch_time_t(DISPATCH_TIME_NOW), dispatch_get_main_queue()) {
            
            /**
             *  将tocken传给服务器，服务器进行账单处理，扣款等业务，让后将是否成功告诉APP
             */
            print(payment)
            isSceess = true
            if isSceess {
                /**
                 付款成功
                 */
                completion(PKPaymentAuthorizationStatus.Success)
            }else{
                /**
                 付款失败
                 */
                if #available(iOS 9.2, *) {
                    /**
                     *  PINIncorrect,指纹验证成功，银行卡密码输入错误
                     * InvalidShippingContact没输入联系人
                     * InvalidBillingPostalAddress 没输入账单邮寄地址
                     *InvalidShippingPostalAddress 没输送货地址
                     *Failure 提示未完成支付
                     */
                    completion(PKPaymentAuthorizationStatus.PINIncorrect)
                    
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        
    }
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController) {
        print("授权完成")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

