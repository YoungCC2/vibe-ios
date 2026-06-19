//
//  PersonaEditView.swift
//  Vibe
//
//  创建/编辑 AI 评价人设
//

import SwiftUI

struct PersonaEditView: View {
    enum Mode {
        case create
        case edit(AiPersona)
    }

    let mode: Mode
    let onSaved: () -> Void

    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var persona = ""
    @State private var style: PersonaStyle = .casual
    @State private var enabled = true
    @State private var isSaving = false
    @State private var toast: ToastConfig?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 名称
                    VStack(alignment: .leading, spacing: 8) {
                        Text("人设名称")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.vibeTextSecondary)
                        TextField("例如：毒舌评委", text: $name)
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.vibeInputBg)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // 风格选择
                    VStack(alignment: .leading, spacing: 8) {
                        Text("评价风格")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.vibeTextSecondary)
                        PersonaStylePicker(selected: $style)
                    }

                    // 人设描述
                    VStack(alignment: .leading, spacing: 8) {
                        Text("人设描述")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.vibeTextSecondary)
                        TextEditor(text: $persona)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(Color.vibeInputBg)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    // 启用开关
                    HStack {
                        Text("启用")
                            .font(.vibeBody)
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $enabled)
                            .labelsHidden()
                            .tint(.vibeAccent)
                    }
                    .padding(16)
                    .glassCard(cornerRadius: 20)

                    // 删除按钮（编辑模式）
                    if case .edit(let p) = mode {
                        Button(role: .destructive) {
                            Task { await deletePersona(id: p.id) }
                        } label: {
                            Text("删除此人设")
                                .font(.vibeBody)
                                .foregroundColor(Color(hex: "fda4af"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .background(VibeBackground())
            .navigationTitle(isCreate ? "新建人设" : "编辑人设")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                        .foregroundColor(.vibeTextTertiary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task { await save() }
                    }
                    .disabled(name.isEmpty || persona.isEmpty || isSaving)
                    .foregroundColor(name.isEmpty || persona.isEmpty ? .vibeTextTertiary : .vibeAccent)
                }
            }
            .onAppear { loadData() }
            .toast($toast)
        }
    }

    private var isCreate: Bool {
        if case .create = mode { return true }
        return false
    }

    private func loadData() {
        if case .edit(let p) = mode {
            name = p.name
            persona = p.persona
            style = p.style
            enabled = p.enabled
        }
    }

    private func save() async {
        guard !name.isEmpty, !persona.isEmpty else { return }
        isSaving = true
        do {
            switch mode {
            case .create:
                _ = try await AiReviewService.shared.createPersona(name: name, persona: persona, style: style, enabled: enabled)
            case .edit(let p):
                _ = try await AiReviewService.shared.updatePersona(id: p.id, name: name, persona: persona, style: style, enabled: enabled)
            }
            onSaved()
            dismiss()
        } catch {
            toast = ToastConfig(message: "保存失败")
        }
        isSaving = false
    }

    private func deletePersona(id: UInt64) async {
        do {
            try await AiReviewService.shared.deletePersona(id: id)
            onSaved()
            dismiss()
        } catch {
            toast = ToastConfig(message: "删除失败")
        }
    }
}

// MARK: - 风格选择器
struct PersonaStylePicker: View {
    @Binding var selected: PersonaStyle

    var body: some View {
        HStack(spacing: 8) {
            ForEach(PersonaStyle.allCases, id: \.self) { style in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selected = style
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: style.icon)
                            .font(.system(size: 16))
                        Text(style.label)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundColor(selected == style ? .white : .vibeTextTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selected == style ?
                        LinearGradient(colors: [Color.vibeAccent.opacity(0.3), Color.vibeAccent.opacity(0.15)], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [Color.clear, Color.clear], startPoint: .top, endPoint: .bottom)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selected == style ? Color.vibeAccent.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}
