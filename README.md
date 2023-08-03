# Termux chroot / proot with Wine, Box86, and GPU

## Next branch

This branch is used to test the new features and refactoring before integrate to the main branch.

## Getting started

You can set up everything using this command in Termux (Github version).

This uses the **next** branch, not main:

    yes | pkg update -y && pkg install -y wget && wget https://raw.githubusercontent.com/cheadrian/termux-chroot-proot-wine-box86_64/next/Scripts/Getting_Started.sh && chmod +x Getting_Started.sh && ./Getting_Started.sh && rm Getting_Started.sh