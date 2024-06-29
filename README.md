# ~ 🍭 ~
## Installation

1. Generate ssh key

```bash
$ ssh-keygen -t ed25519 "your@email.com"
```

2. Run the following command

```bash
$ bash -c "$(curl -fsSL https://raw.github.com/chessl/home-config/master/install)"
```

3. Turn off spotlights and config raycast

4. Config LaunchPad
```bash
defaults write com.apple.dock springboard-rows -int 7
defaults write com.apple.dock springboard-columns -int 6; killall Dock
```
