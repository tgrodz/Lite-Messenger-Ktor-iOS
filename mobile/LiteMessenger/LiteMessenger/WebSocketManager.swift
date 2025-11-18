//
//  WebSocketManager.swift
//  LiteMessenger

import Foundation

final class WebSocketManager: NSObject {
    private let url: URL
    private var task: URLSessionWebSocketTask?
    private var session: URLSession!
    private var continuation: AsyncStream<MessageDTO>.Continuation?

    init(url: URL) {
        self.url = url
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }

    func connect(token: String?) {
        var request = URLRequest(url: url)
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        task = session.webSocketTask(with: request)
        task?.resume()
        receiveLoop()
        ping()
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        continuation?.finish()
        continuation = nil
    }

    func stream() -> AsyncStream<MessageDTO> {
        AsyncStream { cont in
            self.continuation = cont
        }
    }

    private func receiveLoop() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure:
                self.disconnect()
            case .success(let msg):
                switch msg {
                case .string(let text):
                    if let data = text.data(using: .utf8),
                       let dto = try? NetworkClient.defaultDecoder.decode(MessageDTO.self, from: data) {
                        self.continuation?.yield(dto)
                    }
                case .data(let data):
                    if let dto = try? NetworkClient.defaultDecoder.decode(MessageDTO.self, from: data) {
                        self.continuation?.yield(dto)
                    }
                @unknown default: break
                }
                self.receiveLoop()
            }
        }
    }

    private func ping() {
        Task.detached { [weak self] in
            while let t = self?.task {
                try? await Task.sleep(nanoseconds: 15 * 1_000_000_000)
                t.sendPing { _ in }
            }
        }
    }
}

extension WebSocketManager: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {}
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {}
}
