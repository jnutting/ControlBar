//
//  EdgeInsets+max.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//

import SwiftUI

extension EdgeInsets {
    func max(_ other: EdgeInsets) -> EdgeInsets {
        EdgeInsets(
            top: Swift.max(top, other.top),
            leading: Swift.max(leading, other.leading),
            bottom: Swift.max(bottom, other.bottom),
            trailing: Swift.max(trailing, other.trailing)
        )
    }
}
