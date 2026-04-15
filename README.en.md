# Clipboard

English | [简体中文](README.md) | [日本語](README.ja.md)

A local clipboard management macOS application based on **Swift + SwiftUI + SwiftData**.

## Core Features

* **Multi-type Support**: Supports management of multiple types of content such as text, images, and files.
* **History Management**: Automatically monitors system clipboard changes, saves history records, and supports re-copying and using.
* **Fast Retrieval and Filtering**: Supports keyword search, as well as multi-dimensional combined filtering by content type, category, and favorite status.
* **Categories and Favorites**: Supports custom category management (create, edit, delete), and allows marking frequently used records as favorites.
* **Privacy Protection**: Supports automatic filtering of sensitive content (passwords, tokens, verification codes, etc.) and application blacklist configuration.

## Tech Stack

* **Platform**: macOS 14+
* **Language**: Swift
* **UI Framework**: SwiftUI
* **Data Persistence**: SwiftData

## Architecture Design

The project adopts a clear layered architecture (MVVM + Service):
* **Models**: Data model layer, including clipboard records (`ClipboardItem`), categories (`Category`), and global settings (`AppSettings`).
* **Services**: Business logic layer, including clipboard monitoring (`ClipboardMonitorService`), data persistence (`ClipboardStorageService`), file storage (`FileStorageService`), and privacy filtering (`PrivacyFilterService`).
* **ViewModels**: View model layer, responsible for state management and view logic processing.
* **Views**: View layer, designed with the native macOS three-column structure (`NavigationSplitView`).

## Data Privacy and Security

* **Completely Localized**: All history records and business data are saved only on the local device, with no network dependencies or cloud synchronization behavior.
* **Sensitive Information Protection**: A conservative strategy of "intercept and do not save" is adopted by default for suspected sensitive text.
* **Large File Storage Optimization**: Images are only saved to a local directory and their paths are recorded to avoid database bloat; files only save reference paths and do not copy the physical files.
