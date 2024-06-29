{ pkgs, lib, config, ... }:

let

  cfg = config.my.modules.macos;

in
{
  options = with lib; {
    my.modules.macos = {
      enable = mkEnableOption ''
        Whether to enable macos module
      '';
    };
  };

  config = with lib;
    mkIf cfg.enable {
      environment.variables = {
        LANG = "en_US.UTF-8";
        LC_TIME = "en_GB.UTF-8";
      };

      security.pam.enableSudoTouchIdAuth = true;

      system = {
        defaults = {
          # ".GlobalPreferences".com.apple.sound.beep.sound = "Funk";

          # Enable quarantine for downloaded applications
          LaunchServices.LSQuarantine = false;
          SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

          # smb = {
          #   # Hostname to use for NetBIOS
          #   NetBIOSName = config.my.hostName;

          #   # Hostname to use for sharing services
          #   ServerDescription = config.my.hostName;
          # };

          CustomSystemPreferences = {
            "com.apple.Safari" = {
              "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
            };
          };

          screencapture = {
            # Disable drop shadow border around screencaptures
            disable-shadow = true;

            # location = "";
          };

          loginwindow = {
            GuestEnabled = false;

            # Disable the ability for a user to access the console by typing “>console” for a username at the login window.
            DisableConsoleAccess = true;
          };

          NSGlobalDomain = {
            AppleFontSmoothing = 2;

            # Disable swiping left or right with two fingers to navigate backward or forward
            AppleEnableSwipeNavigateWithScrolls = false;
            AppleEnableMouseSwipeNavigateWithScrolls = false;

            # Dark mode
            AppleInterfaceStyle = "Dark";

            # Enable full keyboard control
            AppleKeyboardUIMode = 3;

            # Use metric system
            AppleTemperatureUnit = "Celsius";
            AppleMeasurementUnits = "Centimeters";
            AppleMetricUnits = 1;

            # Disable press-and-hold feature
            ApplePressAndHoldEnabled = false;

            # Show all file extensions in Finder
            AppleShowAllExtensions = true;

            # Always show scrollbars
            AppleShowScrollBars = "Always";

            # Faster key repeat
            InitialKeyRepeat = 10;
            KeyRepeat = 1;

            # Disable automatic capitalization 
            NSAutomaticCapitalizationEnabled = false;

            # Disable smart dash substitution
            NSAutomaticDashSubstitutionEnabled = false;

            # Disable smart quote substitution
            NSAutomaticQuoteSubstitutionEnabled = false;

            # Disable automatic spelling correction
            NSAutomaticSpellingCorrectionEnabled = false;

            # Whether to save new documents to iCloud by default
            # NSDocumentSaveNewDocumentsToCloud = false;

            # Expand save panel by default
            NSNavPanelExpandedStateForSaveMode = true;
            NSNavPanelExpandedStateForSaveMode2 = true;

            # Size of the finder sidebar icons
            NSTableViewDefaultSizeMode = 1;

            # Display ASCII control characters using caret notation in standard text views
            NSTextShowsControlCharacters = true;

            # Faster window resizing
            NSWindowResizeTime = 0.001;

            # Expand print panel by default
            PMPrintingExpandedStateForPrint = true;
            PMPrintingExpandedStateForPrint2 = true;

            # Autohide the menu bar
            _HIHideMenuBar = false;

            # Enable tap to click
            "com.apple.mouse.tapBehavior" = 1;
            # com.apple.sound.beep.feedback = 0;
            # com.apple.springing.delay = 0;
            # com.apple.springing.enabled = true;
          };

          dock = {
            # System Preferences > Dock > Position on screen: Left
            orientation = "left";

            # System Preferences > Dock > Automatically hide and show the Dock:
            autohide = true;

            # System Preferences > Dock > Automatically hide and show the Dock (delay)
            autohide-delay = 0.0;

            # System Preferences > Dock > Automatically hide and show the Dock (duration)
            autohide-time-modifier = 0.0;

            # Disable dashboard
            dashboard-in-overlay = true;
            expose-animation-duration = 0.1;
            expose-group-by-app = false;
            launchanim = false;
            mineffect = "genie";

            # System Preferences > Dock > Minimize windows into application icon
            minimize-to-application = true;
            mouse-over-hilite-stack = true;

            # System Preferences > Dock > Show indicators for open applications
            show-process-indicators = true;
            show-recents = false;
            showhidden = true;
            # Show only open applications in the Dock. The default is false.
            static-only = true;
            tilesize = 32;
            # Hot corners, reset them all.
            # Hot corner top-right - notification center
            wvous-tr-corner = 12;
            # Hot corner bottom-right - desktop
            wvous-br-corner = 4;
            # Hot corner bottom-left - launchpad
            wvous-bl-corner = 11;

          };

          finder = {
            # Whether to always show file extensions
            AppleShowAllExtensions = true;
            # QuitMenuItem = true;
            _FXShowPosixPathInTitle = false; # In Big Sur this is so UGLY!

            # Disable warnings when change the file extension of files
            FXEnableExtensionChangeWarning = false;

            # Change the default finder view to list
            FXPreferredViewStyle = "Nlsv";

            # Show path breadcrumbs in finder windows
            ShowPathbar = true;

            # Show status bar at bottom of finder windows with item/disk space stats
            ShowStatusBar = true;
          };

          trackpad = {
            # Tap to click
            Clicking = true;
            TrackpadRightClick = true;
            Dragging = false;
            # Enable three finger drag
            TrackpadThreeFingerDrag = true;
          };

          alf = {
            # Drops incoming requests via ICMP such as ping requests
            stealthenabled = 1;

            # Enable the internal firewall to prevent unauthorised applications, programs and services from accepting incoming connections
            globalstate = 1;
          };
        };

        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToControl = true;
          # remapCapsLockToEscape = true;
        };

      };
    };
}
