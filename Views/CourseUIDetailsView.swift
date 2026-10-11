//
//  CourseUIDetailsView.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 09/10/26.
//

import SwiftUI

struct CourseUIDetailsView: View {

    @StateObject private var viewModel: CourseDetailsViewModel


    init(course: CourseModel) {
        _viewModel = StateObject(
            wrappedValue: CourseDetailsViewModel(course: course)
        )

    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                courseHeader

                if viewModel.isLoading {

                    ProgressView("Loading lessons...")
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)

                } else if !viewModel.errorMessage.isEmpty {

                    errorView

                } else {

                    lessonsSection
                }
            }
            .padding()
        }
        .navigationTitle("Course Details")
        .task {
            await viewModel.loadLessons()
        }
    }

    // MARK: - Course Header

    private var courseHeader: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text(viewModel.course.title)
                .font(.title2)
                .fontWeight(.bold)

            Text("Instructor: \(viewModel.course.instructor)")
                .foregroundStyle(.secondary)

            HStack {

                Text("\(Int(viewModel.progress))% completed")

                Spacer()

                Text(
                    "\(viewModel.completedLessons)/\(viewModel.lessons.count) lessons"
                )
            }
            .font(.subheadline)

            ProgressView(value: viewModel.progress / 100)
        }
    }

    // MARK: - Lessons

    private var lessonsSection: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Lessons")
                .font(.headline)

            ForEach(viewModel.lessons) { lesson in

                Button {

                    Task {
                        await viewModel.completeLesson(lesson)

                    }

                } label: {

                    HStack(spacing: 12) {

                        Image(
                            systemName: lesson.isCompleted
                            ? "checkmark.circle.fill"
                            : "circle"
                        )
                        .font(.title3)

                        Text(lesson.title)
                            .foregroundStyle(.primary)

                        Spacer()

                        if lesson.isCompleted {

                            Text("Completed")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                        } else {

                            Text("Tap to complete")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                Color.gray.opacity(0.3)
                            )
                    )
                }
                .buttonStyle(.plain)
                .disabled(lesson.isCompleted)
            }
        }
    }

    // MARK: - Error

    private var errorView: some View {
        VStack(spacing: 12) {

            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))

            Text(viewModel.errorMessage)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Retry") {
                Task {
                    await viewModel.loadLessons()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }
}

#Preview {
    NavigationView {
        CourseUIDetailsView(
            course: CourseModel(
                id: 1,
                title: "Python Programming",
                instructor: "John Smith",
                progress: 65,
                lessonsCount: 20
            )
        )
    }
}
