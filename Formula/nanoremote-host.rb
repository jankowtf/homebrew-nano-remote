class NanoremoteHost < Formula
  desc "NanoRemote Host - macOS remote desktop server"
  homepage "https://github.com/jankowtf/homebrew-nano-remote"
  version "0.0.1"
  license "MIT"

  depends_on :macos => :sonoma # macOS 14+ required (ScreenCaptureKit APIs)

  on_arm do
    url "https://github.com/jankowtf/homebrew-nano-remote/releases/download/v0.0.1/nano-remote-host-0.0.1-arm64-macos.tar.gz"
    sha256 "3e0cd10de9a0d720677c5b0324ba251b099f6f88b4bcb73270de954a4800d15d"
  end

  def install
    # Install the .app bundle (contains Info.plist + icon for macOS Settings)
    prefix.install "NanoRemote Host.app"

    # Symlink the binary so it's available on PATH
    bin.install_symlink prefix/"NanoRemote Host.app/Contents/MacOS/nano-remote-host"
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

  # brew services — run via the .app bundle so macOS shows the correct icon
  service do
    run [opt_prefix/"NanoRemote Host.app/Contents/MacOS/nano-remote-host",
         "--mode", "jpeg", "--display", "0"]
    keep_alive true
    log_path var/"log/nanoremote-host.log"
    error_log_path var/"log/nanoremote-host.error.log"
    require_root false
  end

  test do
    assert_match "nano-remote-host", shell_output("#{bin}/nano-remote-host --help 2>&1")
  end
end
