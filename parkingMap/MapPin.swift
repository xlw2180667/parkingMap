//
//  MapPin.swift
//  parkingMap
//
//  Created by Xie Liwei on 2016/11/7.
//  Copyright © 2016年 Xie Liwei. All rights reserved.
//

import UIKit
import MapKit
class MapPin: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    
    init(title: String,coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }
}
