class NanoremoteHost < Formula
  desc "NanoRemote Host - macOS remote desktop server"
  homepage "https://github.com/jankowtf/nano-remote"
  version "0.0.1"
  license "MIT"

  depends_on :macos => :sonoma # macOS 14+ required (ScreenCaptureKit APIs)

  on_arm do
    url "https://github.com/jankowtf/homebrew-nano-remote/releases/download/v0.0.1/nano-remote-host-0.0.1-arm64-macos.tar.gz"
    sha256 "3bb28bae98692781eb9fb09583a6120727af6c0730917429d5e1e2cf66bdf308"
  end

  def install
    bin.install "nano-remote-host"
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
    require_root false
  end

  test do
    assert_match "nano-remote-host", shell_output("#{bin}/nano-remote-host --help 2>&1")
  end
end
