prog := "hey"

# Get version from git tags
version := `git describe --tags --always --dirty 2>/dev/null || echo "0.0.0-dev"`

# Default recipe to show available commands
default:
    @just --list

# Build flags with version information
build_flags := "-ldflags='-s -w -X main.heyUA=hey/" + version + "' -trimpath"

# Show current version
version:
    @echo {{version}}

# Build for the current platform
build:
    @echo "Building {{prog}} version {{version}}..."
    go build {{build_flags}} -o {{prog}}

docker-build:
    docker buildx build -t hey --build-arg build_flags={{build_flags}}  .

# Clean build artifacts
clean:
    rm -rf dist
    rm -f {{prog}} {{prog}}.exe

# Create distribution directory
create-dist:
    mkdir -p dist

# Build for a specific platform and architecture
build-for os arch:
    @echo "Building for {{os}} ({{arch}}) version {{version}}..."
    @mkdir -p dist
    @if [ "{{os}}" = "windows" ]; then \
        GOOS={{os}} GOARCH={{arch}} go build {{build_flags}} -o dist/{{prog}}-{{os}}-{{arch}}.exe; \
    else \
        GOOS={{os}} GOARCH={{arch}} go build {{build_flags}} -o dist/{{prog}}-{{os}}-{{arch}}; \
    fi
    @if [ "{{os}}" = "windows" ]; then \
        echo "✓ Built dist/{{prog}}-{{os}}-{{arch}}.exe"; \
    else \
        echo "✓ Built dist/{{prog}}-{{os}}-{{arch}}"; \
    fi

# Build for all platforms (linux, macos, windows) and architectures (amd64, arm64)
build-all: clean create-dist
    just build-for linux amd64
    just build-for linux arm64
    just build-for darwin amd64
    just build-for darwin arm64
    @echo "All builds completed successfully!"
    @ls -la dist/

# Build for Linux amd64
build-linux-amd64:
    @just build-for linux amd64

# Build for Linux arm64
build-linux-arm64:
    @just build-for linux arm64

# Build for macOS amd64
build-macos-amd64:
    @just build-for darwin amd64

# Build for macOS arm64
build-macos-arm64:
    @just build-for darwin arm64

# Build for Windows amd64
build-windows-amd64:
    @just build-for windows amd64

# Build for Windows arm64
build-windows-arm64:
    @just build-for windows arm64

# Create archive for a specific build
create-archive os arch:
    @echo "Creating archive for {{os}}/{{arch}} with documentation..."
    @cp README.md dist/
    @if [ -f LICENSE ]; then cp LICENSE dist/; fi
    @if [ "{{os}}" = "windows" ]; then \
        cd dist && \
        cp {{prog}}-{{os}}-{{arch}}.exe {{prog}}.exe && \
        zip {{prog}}-{{version}}-{{os}}-{{arch}}.zip {{prog}}.exe README.md $([ -f LICENSE ] && echo "LICENSE"); \
    else \
        cd dist && \
        cp {{prog}}-{{os}}-{{arch}} {{prog}} && \
        tar -czf {{prog}}-{{version}}-{{os}}-{{arch}}.tar.gz {{prog}} README.md $([ -f LICENSE ] && echo "LICENSE"); \
    fi
    @rm -f dist/README.md dist/LICENSE dist/{{prog}}{,.exe} 2>/dev/null
    @echo "✓ Archive created for {{os}}/{{arch}}"

# Create release archives
package: build-all
    @echo "Creating release archives..."
    just create-archive linux amd64
    just create-archive linux arm64
    just create-archive darwin amd64
    just create-archive darwin arm64
    @echo "✓ Created release archives in dist/"

# Run tests
test:
    go test -v ./...

# Install locally
install: build
    @echo "Installing to /usr/local/bin/{{prog}}..."
    sudo cp {{prog}} /usr/local/bin/

# Create a GitHub release and upload distribution files
release: package
    #!/bin/sh -e
    echo "Creating GitHub release for version {{version}}..."
    if [ "$(git status --porcelain)" != "" ]; then \
        echo "Error: Working directory is not clean. Commit or stash changes before creating a release."; \
        exit 1; \
    fi
    if [ "$(git branch --show-current)" != "main" ] && [ "$(git branch --show-current)" != "master" ]; then \
        echo "Warning: You are not on main/master branch. Continue? [y/N]"; \
        read -r answer; \
        if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then \
            echo "Release cancelled."; \
            exit 1; \
        fi; \
    fi
    echo "Checking for GitHub token..."
    if [ -z "$GH_TOKEN" ]; then \
        echo "GH_TOKEN not set, attempting to extract from .netrc file..."; \
        if [ ! -f ~/.netrc ]; then \
            echo "Error: ~/.netrc file not found and GH_TOKEN not set."; \
            echo "Please set GH_TOKEN environment variable or create .netrc with GitHub credentials."; \
            exit 1; \
        fi; \
        GITHUB_TOKEN=$(grep "machine github.com" ~/.netrc | grep "password" | awk '{print $6}') && \
        if [ -z "$GITHUB_TOKEN" ]; then \
            echo "Error: GitHub token not found in .netrc file."; \
            echo "Please ensure your .netrc contains a 'machine github.com' entry with a password or set GH_TOKEN."; \
            exit 1; \
        fi; \
        export GH_TOKEN="$GITHUB_TOKEN"; \
        echo "GitHub token extracted successfully."; \
    else \
        echo "Using existing GH_TOKEN environment variable."; \
    fi
    echo "Finding archive files in dist folder..."
    FILES=$(find dist -type f -name "*.tar.gz" -o -name "*.zip" | tr '\n' ' ') && \
    if [ -z "$FILES" ]; then \
        echo "Error: No archive files found in dist folder"; \
        exit 1; \
    else \
        echo "Found archive files: $FILES"; \
        gh release create {{version}} \
            --title "Release {{version}}" \
            --notes "Release {{version}}" \
            --draft \
            $FILES; \
    fi
    echo "✓ Created draft release {{version}} on GitHub"
    echo "Review and publish the release at: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/releases"
