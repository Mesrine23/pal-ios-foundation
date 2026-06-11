import Foundation
import Testing
@testable import PalPersistence

@Suite("MemoryCache")
struct MemoryCacheTests {

    @Test("Stored value is returned before expiry")
    func storedValueIsReturned() async {
        let cache = MemoryCache()
        let key = CacheKey<String>("greeting", ttl: .seconds(60))

        await cache.set("hello", for: key)

        #expect(await cache.get(key) == "hello")
    }

    @Test("Value expires after its key TTL (passive, delete-on-read)")
    func valueExpiresAfterKeyTTL() async throws {
        let cache = MemoryCache()
        let key = CacheKey<String>("shortLived", ttl: .milliseconds(30))

        await cache.set("temp", for: key)
        try await Task.sleep(for: .milliseconds(80))

        #expect(await cache.get(key) == nil)
    }

    @Test("Per-call TTL overrides the key TTL")
    func perCallTTLOverridesKeyTTL() async throws {
        let cache = MemoryCache()
        let key = CacheKey<String>("overridden", ttl: .seconds(60))

        await cache.set("temp", for: key, ttl: .milliseconds(30))
        try await Task.sleep(for: .milliseconds(80))

        #expect(await cache.get(key) == nil)
    }

    @Test("Key without TTL never expires")
    func keyWithoutTTLNeverExpires() async throws {
        let cache = MemoryCache()
        let key = CacheKey<Int>("eternal")

        await cache.set(42, for: key)
        try await Task.sleep(for: .milliseconds(50))

        #expect(await cache.get(key) == 42)
    }

    @Test("Delete removes the value")
    func deleteRemovesValue() async {
        let cache = MemoryCache()
        let key = CacheKey<String>("deletable")

        await cache.set("value", for: key)
        await cache.delete(key)

        #expect(await cache.get(key) == nil)
    }

    @Test("Clear removes every entry")
    func clearRemovesEverything() async {
        let cache = MemoryCache()
        let first = CacheKey<String>("first")
        let second = CacheKey<Int>("second")

        await cache.set("a", for: first)
        await cache.set(1, for: second)
        await cache.clear()

        #expect(await cache.get(first) == nil)
        #expect(await cache.get(second) == nil)
    }

    @Test("Fresh value within TTL window is still returned")
    func freshValueWithinTTLIsReturned() async throws {
        let cache = MemoryCache()
        let key = CacheKey<String>("fresh", ttl: .seconds(10))

        await cache.set("alive", for: key)
        try await Task.sleep(for: .milliseconds(30))

        #expect(await cache.get(key) == "alive")
    }
}
