## QtAndroidTemplate

QtAndroidTemplate is a starter project for building cross-platform Qt applications targeting Android and desktop environments. It uses CMake for build configuration and Conan for dependency management, with a focus on modularity and modern C++ practices.

### Requirements

- **CMake** (minimum version 3.24)
- **Conan** (for dependency management)
- **Qt** (for application development)
- **fmt** library (as an example dependency)
- **VS Code Extensions** (recommended for development):
	- ms-vscode.cpptools
	- ms-vscode.cmake-tools
	- vadimcn.vscode-lldb
	- cheshirekow.cmake-format
	- ms-vscode.cpptools-extension-pack
	- eamodio.gitlens
	- adelphes.android-dev-ext
	- github.vscode-github-actions
	- josetr.cmake-language-support-vscode
	- llvm-vs-code-extensions.vscode-clangd
	- theqtcompany.qt-qml
	- Delgan.qml-format

### Getting Started

Clone the repository and use CMake and Conan to configure and build the project. See the provided `CMakeLists.txt` and `conanfile.txt` for example usage and dependencies.
# Example Application

There is a small application called QRLite that does nothing except display a white screen

## Building the devcontainer

The devcontainer is available on dockerhub: https://hub.docker.com/repository/docker/bernedom/qtandroidbuilder/general

To build it yourself use docker buildx

```bash
cd .devcontainer
docker buildx build -t bernedom/qtandroidbuilder:dev
```

