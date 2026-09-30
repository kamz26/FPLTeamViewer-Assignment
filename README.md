# FPL Team Viewer

A small programmatic UIKit app that loads Premier League teams and players from the Fantasy Premier League bootstrap API. It supports offline launch, pull-to-refresh, player search, and explicit loading, empty, and error states.

## Build and run

1. Open `FPLTeamViewer.xcodeproj` in Xcode 15 or later.
2. Select the `FPLTeamViewer` scheme and an iOS 17+ simulator.
3. Build and run with **Cmd-R**.
4. Run the unit tests with **Cmd-U**.

The app uses only Apple frameworks and requires network access for its first successful load.

## Architecture

- **MVVM** keeps loading, error, empty, content, and filtered squad state in the view models. UIKit controllers render those states.
- **Router** handles navigation from the teams controller to the squad controller.
- **Diffable table view** shares cell provisioning and snapshot updates; each screen supplies stable team or player IDs and reconfigures only changed rows.
- **Repository** coordinates a `URLSession` API client, DTO-to-domain mapping, and an actor-isolated JSON file cache.
- **Domain models** are independent of API field names and UI code.
- **Protocol-based dependency injection** keeps networking and view-model behavior easy to test.
