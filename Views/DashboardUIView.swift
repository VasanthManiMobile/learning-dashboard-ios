//
//  DashboardUIView.swift
//  LearningDashboardProject
//
//  Created by Vasanth Mani on 09/10/26.
//

import SwiftUI

struct DashboardUIView: View {

    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        NavigationView {
            content
                .navigationTitle("My Learning")
                .task {
                    await viewModel.loadCourses()
                }
        }
    }

    @ViewBuilder
    private var content: some View {

        switch viewModel.state {

        case .loading:
            ProgressView("Loading courses...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .success:
            ScrollView {
                LazyVStack(spacing: 16) {

                    ForEach(viewModel.courses) { course in

                        CourseCardView(course: course)
                    }
                }
                .padding()
            }

        case .empty:
            VStack(spacing: 12) {

                Image(systemName: "book.closed")
                    .font(.system(size: 40))

                Text("No courses available")
                    .font(.headline)

                Text("There are no courses to display right now.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .error(let message):
            VStack(spacing: 16) {

                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))

                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button("Retry") {
                    Task {
                        await viewModel.loadCourses()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Course Card

struct CourseCardView: View {

    let course: CourseModel

    var body: some View {

        NavigationLink {
            CourseUIDetailsView(
                course: course
            )
        } label: {

            VStack(alignment: .leading, spacing: 14) {

                Text(course.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Instructor: \(course.instructor)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {

                    Text("\(Int(course.progress))% completed")

                    Spacer()

                    Text("\(course.lessonsCount) lessons")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                ProgressView(value: course.progress / 100)

                HStack {

                    Spacer()

                    Text("Continue")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.25))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashboardUIView()
}
