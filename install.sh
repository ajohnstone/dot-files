#!/usr/bin/env bash
#
# This installation is destructive, as it removes exisitng files/directories.
# Use at your own risk.

UNAME=$(uname)

for name in *; do
  if [ ! $name == "README.md" -a ! $name == "install.sh" ]; then
    target="$HOME/.$name"

    if [ -h $target ]; then
      rm $target
    elif [ -d $target ]; then
      rm -rf $target
    fi

    case $UNAME in
        CYGWIN* | MINGW32*)
            cp -R "$PWD/$name" "$target"
            echo "Copied $PWD/$name to $target."
            ;;
        *)
            ln -s "$PWD/$name" "$target"
            echo "Linked $PWD/$name to $target."
            ;;
    esac
  fi
done

git submodule init
git submodule update

mkdir -p ~/Desktop/projects/github/ajohnstone/;

(
    rm -rf  ~/Desktop/projects/github/ajohnstone/git-fresh/;
    git clone https://github.com/imsky/git-fresh.git ~/Desktop/projects/github/ajohnstone/git-fresh/;
    cd ~/Desktop/projects/github/ajohnstone/git-fresh/;
    sudo bash ./install.sh;
);

(
    curl -sSL http://git.io/git-extras-setup | sudo bash /dev/stdin
);

(
    cd ~;
    mkdir -p .vim .vim/bundle .vim/backup .vim/swap .vim/cache .vim/undo;
    rm -rf  .vim/bundle/vundle
    git clone https://github.com/gmarik/vundle.git .vim/bundle/vundle
);

