//
//  PersonaListView.swift
//  Vibe
//
//  AI 评价人设管理
//

import SwiftUI

struct PersonaListView: View {
    @State private var personas: [AiPersona] = []
    @State private var isLoading = false
    @State private var editingPersona: AiPersona?
    @State private var showCreate = false
    @State private var toast: ToastConfig?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 说明卡片
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.vibeAccent)
                        Text("AI 评价人设")
                            .font(.vibeSubtitle)
                            .foregroundColor(.white)
                    }
                    Text("每次发布记录后，会随机选一个启用的人设来评价你的内容。关闭的人设不会参与评价。")
                        .font(.system(size: 12))
                        .foregroundColor(.vibeTextSecondary)
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .glassCard(cornerRadius: 20)

                // 人设列表
                LazyVStack(spacing: 12) {
                    ForEach(personas) { persona in
                        PersonaRow(
                            persona: persona,
                            onToggle: { await toggle(persona) },
                            onEdit: { editingPersona = persona }
                        )
                    }
                }

                // 新建人设
                Button {
                    showCreate = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        Text("自定义人设")
                            .font(.vibeBody)
                    }
                    .foregroundColor(.vibeAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [6]))
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(VibeBackground())
        .navigationTitle("AI 评价人设")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadPersonas() }
        .sheet(item: $editingPersona) { persona in
            PersonaEditView(mode: .edit(persona)) {
                Task { await loadPersonas() }
            }
        }
        .sheet(isPresented: $showCreate) {
            PersonaEditView(mode: .create) {
                Task { await loadPersonas() }
            }
        }
        .toast($toast)
    }

    private func loadPersonas() async {
        isLoading = true
        do {
            personas = try await AiReviewService.shared.listPersonas()
        } catch {
            toast = ToastConfig(message: "加载失败")
        }
        isLoading = false
    }

    private func toggle(_ persona: AiPersona) async {
        do {
            let updated = try await AiReviewService.shared.updatePersona(
                id: persona.id,
                name: persona.name,
                persona: persona.persona,
                style: persona.style,
                enabled: !persona.enabled
            )
            if let idx = personas.firstIndex(where: { $0.id == updated.id }) {
                personas[idx] = updated
            }
        } catch {
            toast = ToastConfig(message: "更新失败")
        }
    }
}

// MARK: - 人设行
struct PersonaRow: View {
    let persona: AiPersona
    let onToggle: () async -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // 风格图标
            Image(systemName: persona.style.icon)
                .font(.system(size: 18))
                .foregroundColor(.vibeAccent)
                .frame(width: 44, height: 44)
                .background(Color.vibeNavBg)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 4) {
                Text(persona.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Text(persona.persona)
                    .font(.system(size: 12))
                    .foregroundColor(.vibeTextTertiary)
                    .lineLimit(2)
            }

            Spacer()

            Toggle("", isOn: .constant(persona.enabled))
                .labelsHidden()
                .tint(.vibeAccent)
                .onTapGesture { Task { await onToggle() } }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
        .contentShape(Rectangle())
        .onTapGesture { onEdit() }
    }
}
