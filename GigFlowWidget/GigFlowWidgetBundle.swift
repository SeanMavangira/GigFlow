//
//  GigFlowWidgetBundle.swift
//  GigFlowWidget
//
//  Created by Sean Mavangira on 4/5/2026.
//

import WidgetKit
import SwiftUI

@main
struct GigFlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        GigFlowWidget()
        GigFlowWidgetControl()
        GigFlowWidgetLiveActivity()
    }
}
