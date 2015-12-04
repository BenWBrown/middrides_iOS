//
//  LocationStatus.swift
//  middrides
//
//  Created by Julian Billings on 12/3/15.
//  Copyright © 2015 Ben Brown. All rights reserved.
//

import Foundation
import Parse

class LocationStatus: NSObject, NSCoding {
    
    // MARK: Properties
    
    var latestLocVersion: Int
    var vanStops : [String]
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let archiveLocStatusURL = DocumentsDirectory.URLByAppendingPathComponent("locVersion")
    static let archiveVanStopsURL = DocumentsDirectory.URLByAppendingPathComponent("vStops")
    
    // MARK: Initialization
    
    init(latestLocVersion: Int, vanStops: [String]) {
        self.latestLocVersion = latestLocVersion
        self.vanStops = vanStops
    }
    
    // MARK: NSCoding requriements
    
    required convenience init?(coder aDecoder: NSCoder) {
        let currentVersion = aDecoder.decodeObjectForKey("latestLocVersion") as! Int;
        let currentStops = aDecoder.decodeObjectForKey("vanStops") as! [String];
        self.init(latestLocVersion: currentVersion, vanStops: currentStops);
    }
    
    func encodeWithCoder(aCoder: NSCoder){
        aCoder.encodeInteger(self.latestLocVersion, forKey: "latestLocVersion")
        aCoder.encodeObject(self.vanStops, forKey: "vanStops")
        
    }
    
    //MARK: NSCoding
    
    func saveData(){
        let isSuccessfulSave1 = NSKeyedArchiver.archiveRootObject(self.latestLocVersion, toFile: LocationStatus.archiveLocStatusURL.path!)
        let isSuccessfulSave2 = NSKeyedArchiver.archiveRootObject(self.vanStops, toFile: LocationStatus.archiveVanStopsURL.path!)
        if (!isSuccessfulSave1 || !isSuccessfulSave2){
            print("Save failed")
        }
    }
    
    func loadData() -> (locStatus: Int, stops: [String]) {

        if let savedLocStatus = NSKeyedUnarchiver.unarchiveObjectWithFile(LocationStatus.archiveLocStatusURL.path!) as? Int {
            if let savedStops = NSKeyedUnarchiver.unarchiveObjectWithFile(LocationStatus.archiveVanStopsURL.path!) as? [String]{
                return (savedLocStatus, savedStops)
            } else {
                return (savedLocStatus, [String]())
            }
        } else {
            return (-1, [String]())
        }
    }
    
    // MARK: Instance Methods
    func setVersion (version: Int) {
        self.latestLocVersion = version;
    }
    
    func changeVanStops (stops: [String]) {
        self.vanStops = stops;
    }
    
    func getVersion() -> Int {
        return self.latestLocVersion;
    }
    
}