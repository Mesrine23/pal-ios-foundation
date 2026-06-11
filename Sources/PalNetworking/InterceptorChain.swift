struct InterceptorChain: Sendable {

    let interceptors: [any Interceptor]
    let transport: Next

    func execute(_ request: TransportRequest) async throws(NetworkError) -> NetworkResponse {
        try await proceed(request, index: 0)
    }

    private func proceed(_ request: TransportRequest, index: Int) async throws(NetworkError) -> NetworkResponse {
        guard index < interceptors.count else {
            return try await transport(request)
        }
        let next: Next = { request throws(NetworkError) in
            try await self.proceed(request, index: index + 1)
        }
        return try await interceptors[index].intercept(request, next: next)
    }
}
