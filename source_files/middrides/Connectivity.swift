//
//  Connectivity.swift
//  middrides
//
//  Created by Sherif Nada on 2/16/16.
//  Copyright © 2016 Ben Brown. All rights reserved.
//

/**
Utility class to check if internet connection is active
*/
import Foundation
import SystemConfiguration

public class Connectivity {
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in();
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress));
        zeroAddress.sin_family = sa_family_t(AF_INET);
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        
        var flags = SCNetworkReachabilityFlags()
        
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0 ;
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0 ;
        return (isReachable && !needsConnection)
    }
}