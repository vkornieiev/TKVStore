//
//  TransactionalStoreView.swift
//  TransactionalStore
//
//  Created by Vladyslav Kornieiev on 03/25/23.
//

import SwiftUI

struct TransactionalStoreView: View {
    @StateObject var viewModel = TransactionalStoreViewModel()

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            basicOperationsSection
            countSection
            transactionOperationsSection
            consoleOutputSection
        }
        .padding()
        .onTapGesture {
            viewModel.trigger(.onDismissKeyboard)
        }
        .scrollOnOverflow(true)
        .confirmationDialog(Constants.confirmDialogTitle,
                            isPresented: $viewModel.state.showConfirmDialog,
                            titleVisibility: .visible) {
            Button(Constants.confirmDialogButtonTitle, role: .destructive) {
                viewModel.confirmedAlertAction?()
            }
        }
    }

    private var basicOperationsSection: some View {
        Section(Constants.basicOperationsSectionTitle) {
            HStack {
                TextField(Constants.enterKeyTitle, text: $viewModel.state.key)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .keyboardType(.asciiCapable)
                TextField(Constants.enterValueTitle, text: $viewModel.state.value)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)
                    .autocorrectionDisabled(true)
                    .keyboardType(.asciiCapable)
            }
            HStack {
                TransactionalStoreButton(title: Constants.getButtonTitle, color: .green) {
                    viewModel.trigger(.onGetAction)
                    viewModel.trigger(.onDismissKeyboard)
                }
                TransactionalStoreButton(title: Constants.setButtonTitle, color: .blue) {
                    viewModel.trigger(.onSetAction)
                    viewModel.trigger(.onDismissKeyboard)
                }
                TransactionalStoreButton(title: Constants.deleteButtonTitle, color: .red) {
                    viewModel.trigger(.onDeleteAction)
                    viewModel.trigger(.onDismissKeyboard)
                }
            }
        }
    }

    private var countSection: some View {
        Section(Constants.countSectionTitle) {
            TextField(Constants.enterValueTitle, text: $viewModel.state.value)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .autocorrectionDisabled(true)
                .keyboardType(.asciiCapable)
            TransactionalStoreButton(title: Constants.countButtonTitle, color: .brown) {
                viewModel.trigger(.onCountAction)
                viewModel.trigger(.onDismissKeyboard)
            }
        }
    }

    private var transactionOperationsSection: some View {
        Section(Constants.transactionMethodsSectionTitle) {
            HStack {
                TransactionalStoreButton(title: Constants.beginButtonTitle,
                                            color: .mint) {
                    viewModel.trigger(.onBeginAction)
                    viewModel.trigger(.onDismissKeyboard)
                }
                TransactionalStoreButton(title: Constants.commitButtonTitle,
                                            color: .cyan,
                                            enabled: viewModel.state.storageNestingLevel > .zero) {
                    viewModel.trigger(.onCommitAction)
                    viewModel.trigger(.onDismissKeyboard)
                }
                TransactionalStoreButton(title: Constants.rollbackButtonTitle,
                                            color: .orange,
                                            enabled: viewModel.state.storageNestingLevel > .zero) {
                    viewModel.trigger(.onRollbackActionTapped)
                    viewModel.trigger(.onDismissKeyboard)
                }
            }
        }
    }

    private var consoleOutputSection: some View {
        Section {
            ScrollView(.vertical, showsIndicators: true) {
                ScrollViewReader { proxy in
                    LazyVStack(alignment: .leading, spacing: .zero) {
                        ForEach(viewModel.state.consoleOutput) { message in
                            HStack(spacing: 8) {
                                Rectangle()
                                    .fill(message.color)
                                    .frame(width: 20, height: 20)
                                if message.isError {
                                    Text(Constants.errorMessagePrefix)
                                        .foregroundColor(.red)
                                        .bold()
                                }
                                Text(message.text)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                            .id(message.id)
                        }
                        .onChange(of: viewModel.state.consoleOutput.count) { _ in
                            withAnimation {
                                proxy.scrollTo(viewModel.state.consoleOutput.last?.id)
                            }
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity)
                }
            }
            .scrollContentBackground(.hidden)
            .background(.gray.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(idealHeight: 200)
            Button(Constants.clearConsoleButtonTitle) {
                viewModel.trigger(.onClearConsoleAction)
            }
            .foregroundColor(.red)
        } header: {
            consoleHeader
        }
    }

    private var consoleHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(Constants.operationsIndicatorTitle)
                .foregroundColor(.gray)
                .font(.footnote)
            GeometryReader { geo in
                HStack(spacing: 4) {
                    ForEach(.zero...viewModel.state.storageNestingLevel,
                            id: \.self) {
                        Rectangle().fill(viewModel.colors[$0 % 10])
                            .frame(maxWidth: geo.size.width / 10)
                    }
                }
            }
            .frame(height: 20)
        }
    }

    private struct Constants {
        static let navigationBarTitle = "Transaction Store"
        static let basicOperationsSectionTitle = "GET, SET or DELETE value by key:"
        static let countSectionTitle = "Search occurrences count of the value:"
        static let transactionMethodsSectionTitle = "Create nested transaction(s), commit or discard:"
        static let enterKeyTitle = "Please enter a key"
        static let enterValueTitle = "Please enter a value"
        static let getButtonTitle = "GET"
        static let setButtonTitle = "SET"
        static let deleteButtonTitle = "DELETE"
        static let countButtonTitle = "COUNT"
        static let beginButtonTitle = "BEGIN"
        static let commitButtonTitle = "COMMIT"
        static let rollbackButtonTitle = "ROLLBACK"
        static let errorMessagePrefix = "Error:"
        static let clearConsoleButtonTitle = "Clear console output"
        static let operationsIndicatorTitle = "Nested operations indicator:"
        static let confirmDialogTitle = "Confirm operation?"
        static let confirmDialogButtonTitle = "Confirm"
    }
}

struct TransactionalStoreView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionalStoreView()
    }
}
