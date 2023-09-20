//
//  MainView.swift
//  excerpt
//
//  Created by Richard on 2023/9/11.
//

import SwiftUI

private let animationDuration: CGFloat = 0.2

private extension AnyTransition {
    static var shareViewTrans: AnyTransition {
        AnyTransition.offset(y: 60).combined(with: .opacity)
    }
}

struct MainView: View {
    @State private var showPasteSheet = false

    @State private var excerpt: Excerpt
    @State private var showShareView: Bool

    private enum ExcerptFormField {
        case title
        case author
        case content
    }

    @FocusState private var focusedFormField: ExcerptFormField?

    init() {
        let excerptType = ExcerptType(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKeys.initialExcerptType)) ?? .defaultValue
        self.init(Excerpt(excerptType, title: "", author: "", content: ""), sharing: false)
    }

    init(_ initialExcerpt: Excerpt, sharing: Bool = false) {
        self._excerpt = State(initialValue: initialExcerpt)
        self._showShareView = State(initialValue: sharing)
    }

    var body: some View {
        ZStack {
            NavigationStack {
                Form {
                    Section {
                        Button("PASTE_VIEW_TITLE") {
                            self.showPasteSheet = true
                            self.focusedFormField = nil
                        }

                        Picker("C_EXCERPT_TYPE", selection: self.$excerpt.type) {
                            ForEach(ExcerptType.allCases, id: \.rawValue) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .onChange(of: self.excerpt.type) { newValue in
                            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKeys.initialExcerptType)
                        }
                    }

                    Section("C_TITLE") {
                        TextField("MAIN_VIEW_FORM_TITLE_PLACEHOLDER", text: self.$excerpt.title, axis: .vertical)
                            .focused(self.$focusedFormField, equals: .title)
                    }
                    Section("C_AUTHOR") {
                        TextField("MAIN_VIEW_FORM_AUTHOR_PLACEHOLDER", text: self.$excerpt.author, axis: .vertical)
                            .focused(self.$focusedFormField, equals: .author)
                    }
                    Section("C_CONTENT") {
                        TextField("MAIN_VIEW_FORM_CONTENT_PLACEHOLDER", text: self.$excerpt.content, axis: .vertical)
                            .focused(self.$focusedFormField, equals: .content)
                            .lineLimit(6 ... .max)
                    }

                    Section {
                        Button("A_SHARE") {
                            self.showShareView = true
                        }
                        .disabled(self.excerpt.content.isEmpty)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle("C_APP_NAME")
                .sheet(isPresented: self.$showPasteSheet) {
                    PasteSheetView(excerpt: self.$excerpt)
                }
            }
            .allowsHitTesting(!self.showShareView)
            // another way to blur: https://stackoverflow.com/a/59111492
            .blur(radius: self.showShareView ? 20 : 0)
            .overlay(self.showShareView ? Color.gray.opacity(0.2) : Color.clear)
            .animation(.easeInOut(duration: animationDuration), value: self.showShareView)

            if self.showShareView {
                ShareView(isPresented: self.$showShareView, excerpt: self.excerpt)
                    .zIndex(1) // to fix animation: https://sarunw.com/posts/how-to-fix-zstack-transition-animation-in-swiftui/
                    .transition(.shareViewTrans)
            }
        }
        .animation(.easeInOut(duration: animationDuration), value: self.showShareView)
    }
}

#Preview("Empty") {
    MainView()
        .environment(\.locale, .init(identifier: "zh-Hans"))
}

#Preview("Non-empty English") {
    MainView(demoExcerpts[0])
        .environment(\.locale, .init(identifier: "en"))
}
