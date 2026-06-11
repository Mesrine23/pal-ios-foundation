/// How a flow modal is presented.
public enum ModalStyle: Sendable, Equatable {

    /// A standard sheet.
    case sheet

    /// A full-screen cover (iOS only; falls back to a sheet elsewhere).
    case fullScreenCover
}
