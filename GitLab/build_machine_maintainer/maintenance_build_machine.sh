#!/bin/sh

# CocoaPods Repo更新
/usr/local/bin/pod repo update

# Homebrewアップデート(パッケージの更新はしない)
/usr/local/bin/brew update

# ruby-buildを更新(Rubyのバージョンリスト)
/usr/local/bin/brew upgrade ruby-build

# DerivedDataをクリーンアップ
rm -rf ~/Library/Developer/Xcode/DerivedData/
