import SwiftUI

public struct Backport<Content: View> {
	let content: Content
}

public extension View {
	var backport: Backport<Self> { .init(content: self) }
}
