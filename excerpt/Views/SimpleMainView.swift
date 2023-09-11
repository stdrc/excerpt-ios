//
//  SimpleMainView.swift
//  excerpts
//
//  Created by Richard on 2023/9/11.
//

import SwiftUI

let animationDuration: CGFloat = 0.2
let backgroundBlurRadius: CGFloat = 20

let booksExcerptTplt = /^“([\S\s]*)”\s*摘录来自\n([^\n]+)\n([^\n]+)\n此材料受版权保护。$/

struct PasteSheetView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var pasted: String

    var body: some View {
        NavigationStack {
            Form {
                TextField(LocalizedStringKey("Please paste excerpt here."), text: self.$pasted, axis: .vertical)
                    .lineLimit(10 ... .max)
                    .frame(maxHeight: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(LocalizedStringKey("Paste from Books"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedStringKey("Cancel")) {
                        self.pasted = ""
                        self.dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedStringKey("Done")) {
                        self.dismiss()
                    }
                    .disabled(self.pasted.isEmpty)
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

struct ShareView: View {
    @Binding var isPresented: Bool

    func dismiss() {
        withAnimation(.easeInOut(duration: animationDuration)) {
            self.isPresented = false
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Text("Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!Hello, World!")
                            .background(Color.red)
                            .onTapGesture {
                                self.dismiss()
                            }
                    }
                    .padding([.leading, .trailing], 10)
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height - 40)
                }
//                .background(Color.blue)
                .onTapGesture {
                    self.dismiss()
                }

                HStack {
                    Text("Btn1")
                        .background(Color.purple)

                    Text("Btn2")
                        .background(Color.yellow)
                }
                .frame(width: geometry.size.width, height: 40)
                .background(Color.green)
            }
            .padding(0)
        }
    }
}

extension AnyTransition {
    static var shareViewTrans: AnyTransition {
        AnyTransition.offset(y: 60).combined(with: .opacity)
    }
}

struct SimpleMainView: View {
    @State private var showPasteSheet = false
    @State private var pasted = ""
    @State private var showBadPasteAlert = false

    @State private var content = ""
    @State private var book = ""
    @State private var author = ""

    @State private var showShareView = false

    func handlePasted() {
        let pasted = self.pasted
        if pasted.isEmpty {
            return
        }
        self.pasted = ""

        print("Pasted: \(pasted)")

        if let match = pasted.wholeMatch(of: booksExcerptTplt) {
            self.content = String(match.1)
            self.book = String(match.2)
            self.author = String(match.3)
        } else {
            self.showBadPasteAlert = true
        }
    }

    var body: some View {
        ZStack {
            NavigationStack {
                Form {
                    Button(LocalizedStringKey("Paste from Books")) {
                        self.pasted = ""
                        self.showPasteSheet = true
                    }
                    .sheet(isPresented: self.$showPasteSheet, onDismiss: self.handlePasted) {
                        PasteSheetView(pasted: self.$pasted)
                    }
                    .alert(LocalizedStringKey("Not a valid excerpt from Books."), isPresented: self.$showBadPasteAlert) {
                        Button(LocalizedStringKey("OK"), role: .cancel) {}
                    }

                    Section(header: Text(LocalizedStringKey("Content"))) {
                        TextField(LocalizedStringKey("Please enter excerpt content here."), text: self.$content, axis: .vertical)
                            .lineLimit(6 ... .max)
                    }
                    Section(header: Text(LocalizedStringKey("Book"))) {
                        TextField(LocalizedStringKey("Please enter the book name here."), text: self.$book, axis: .vertical)
                    }
                    Section(header: Text(LocalizedStringKey("Author"))) {
                        TextField(LocalizedStringKey("Please enter the author name here."), text: self.$author, axis: .vertical)
                    }

                    Button(LocalizedStringKey("Share")) {
                        withAnimation(.easeInOut(duration: animationDuration)) {
                            self.showShareView = true
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle(LocalizedStringKey("Excerpt"))
            }
            .allowsHitTesting(!self.showShareView)
            // another way to blur: https://stackoverflow.com/a/59111492
            .blur(radius: { if self.showShareView {
                backgroundBlurRadius
            } else {
                0
            } }())
            .animation(.easeInOut(duration: animationDuration), value: self.showShareView)

            if self.showShareView {
                ShareView(isPresented: self.$showShareView)
                    .zIndex(1) // to fix animation: https://sarunw.com/posts/how-to-fix-zstack-transition-animation-in-swiftui/
                    .transition(.shareViewTrans)
            }
        }
    }
}

#Preview {
    SimpleMainView()
}
