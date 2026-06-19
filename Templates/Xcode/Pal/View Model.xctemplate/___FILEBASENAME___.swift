import Observation
import PalPresentation

@MainActor @Observable
final class ___FILEBASENAME___ {

    let <#section#> = Loader<<#Value#>>()

    @ObservationIgnored private let <#useCase#>: <#UseCaseProtocol#>

    init(<#useCase#>: <#UseCaseProtocol#>) {
        self.<#useCase#> = <#useCase#>
    }

    func load() async {
        await <#section#>.performLoad { [<#useCase#>] in
            try await <#useCase#>.execute()
        }
    }
}
