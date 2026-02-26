class NanoremoteHost < Formula
  desc "NanoRemote Host - macOS remote desktop server"
  homepage "https://gitlab.kaosmaps.com/kaosmaps/nano-remote"
  url "https://gitlab.kaosmaps.com/kaosmaps/nano-remote/-/archive/v0.0.1/nano-remote-v0.0.1.tar.gz"
  version "0.0.1"
  # sha256 will be filled after first GitLab release is published
  sha256 "bd208eb91d0b7c7d37d0d760d312aea7a745307d9f488faaed3e62093c845b32"
  license "MIT"

  depends_on :macos => :sonoma # macOS 14+ required (ScreenCaptureKit APIs)

  # Rust is required to build from source
  depends_on "rust" => :build

  def install
    # Build the host binary from source
    system "cargo", "build", "--release", "-p", "nano-remote-host"
    bin.install "target/release/nano-remote-host"

    # Install the viewer web files (served alongside the host)
    (share/"nanoremote/viewer-web").install Dir["viewer-web/*"]

    # Install LaunchAgent plist into the formula prefix so
    # `brew services` can manage it via the service block below
    # The plist is also available at opt_prefix for manual installs
  end

  def caveats
    <<~EOS
      NanoRemote Host requires two macOS permissions before it can function:

        - Screen Recording  (to capture and stream your display)
        - Accessibility     (to inject mouse and keyboard events)

      Grant both in:
        System Settings > Privacy & Security > Screen Recording
        System Settings > Privacy & Security > Accessibility

      -----------------------------------------------------------------------
      STARTING THE HOST
      -----------------------------------------------------------------------
      Via brew services (recommended — auto-starts on login):
        brew services start nanoremote-host

      Manually (foreground, useful for debugging):
        nano-remote-host --mode jpeg --display 0

      -----------------------------------------------------------------------
      STOPPING THE HOST
      -----------------------------------------------------------------------
        brew services stop nanoremote-host

      -----------------------------------------------------------------------
      LOGS
      -----------------------------------------------------------------------
        tail -f #{var}/log/nanoremote-host.log
        tail -f #{var}/log/nanoremote-host.error.log

    EOS
  end

  # brew services integration — generates and manages the LaunchAgent plist
  service do
    run [opt_bin/"nano-remote-host", "--mode", "jpeg", "--display", "0"]
    keep_alive true
    log_path var/"log/nanoremote-host.log"
    error_log_path var/"log/nanoremote-host.error.log"
    # Run immediately when the LaunchAgent is loaded (i.e. on login)
    require_root false
  end

  test do
    # Verify the binary exists and responds to --help
    assert_match "nano-remote-host", shell_output("#{bin}/nano-remote-host --help 2>&1")
  end
end
