# Xcode file templates

Custom **File Templates** that scaffold Pal's canonical patterns, so *New File…* offers a **Pal** section.

| Template | Generates |
|---|---|
| **Use Case** | `‹Name›UseCaseProtocol` + `‹Name›UseCase` (single `execute`, constructor-injected dependency). Name the file `FetchUsersUseCase`. |
| **View Model** | `@MainActor @Observable final class ‹Name›` holding a `Loader`, loading via an injected use case. Name the file `UsersListViewModel`. |

The file name you type becomes the type name — `___FILEBASENAME___` — so a "Use Case" file named `FetchUsersUseCase` yields `FetchUsersUseCaseProtocol` + `FetchUsersUseCase`.

## Install

Copy the templates into Xcode's user template directory, then restart Xcode:

```bash
DEST="$HOME/Library/Developer/Xcode/Templates/File Templates/Pal"
mkdir -p "$DEST"
cp -R "Templates/Xcode/Pal/." "$DEST/"
```

They then appear under **File ▸ New ▸ File from Template… ▸ Pal**. Fill the `<#placeholders#>` (⇥ jumps between them).

## Uninstall

```bash
rm -rf "$HOME/Library/Developer/Xcode/Templates/File Templates/Pal"
```
