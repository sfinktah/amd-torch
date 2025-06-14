# README: Using PyTorch Alpha Wheels on Windows with AMD GPUs

**"Unofficial PyTorch alpha wheels for AMD GPUs on Windows. Because official support is a myth, and I like my deep learning with extra driver panic."**

**"Running PyTorch on Windows with AMD GPUs using alpha ROCm wheels. It's fast, it's fragile, and it hates you back."**

## This repo was nearly called...

* torch-til-it-breaks
* rocm-rock-bottom
* amd-does-windows
* torch-on-the-rocks
* theRock-for-Windows
* rage-against-the-nvidia
* gpu-pain-club
* rdna2-electric-boogaloo
* torch-me-harder
* comfy-in-hell
* torch-this-garbage
* winrocmtothemoon
* amdgoddammit
* pytorch-but-worse
* rdna-barely
* miohell
* comfy-but-clenched
* rock-bottom-torch
* torch-the-house-down
* wheeled-chaos
* who-needs-drivers-anyway

## Index

* [Overview](#overview)
* [System Requirements](#system-requirements)
* [Installing Python](#installing-python)
* [Installing Git](#installing-git)
* [Setting Up Your Working Directory](#setting-up-your-working-directory)
* [Cloning and Preparing ComfyUI](#cloning-and-preparing-comfyui)
* [Linking Shared Directories](#linking-shared-directories)
* [Migrating Custom Nodes](#migrating-custom-nodes)
* [ComfyUI Startup Script](#comfyui-startup-script)
* [Installing WAN2GP](#installing-wan2gp)
* [Performance Notes and Bugs](#performance-notes-and-bugs)

---

## Overview

These wheels are hosted at [scottt's rocm-TheRock releases](https://github.com/scottt/rocm-TheRock/releases). Find the heading that says:

**Pytorch wheels for gfx110x, gfx1151, and gfx1201**

Don't click this link: [https://github.com/scottt/rocm-TheRock/releases/tag/v6.5.0rc-pytorch-gfx110x](https://github.com/scottt/rocm-TheRock/releases/tag/v6.5.0rc-pytorch-gfx110x). It's just here to check if you're skimming.

You are going to be installing a fresh ComfyUI setup in a new directory. All of this was battle-tested with:

* Python 3.11 (or 3.12)
* ROCm 6.5.0rc
* PyTorch 2.7 alpha
* AMD GPU: `gfx110x`, `gfx1151`, or `gfx1201`

If you're not on one of those, go back to whatever cave your driver lives in.

---

## System Requirements

You must have:

* Windows (obviously)
* An AMD GPU with the correct architecture
* Python 3.11 or 3.12
* Git
* Enough patience to not break your own kneecaps when torch fails to load

---

## Installing Python

Download Python 3.11 from [python.org/downloads/windows](https://www.python.org/downloads/windows/). Hit Ctrl+F and search for "3.11". Don’t use this direct link: [https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe](https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe) — again, that’s a test. Use your eyes.

After installing, make sure `python --version` works in your terminal.

If not, fix your PATH. Go to:

* Windows + Pause/Break
* Advanced System Settings
* Environment Variables
* Edit your `Path` under User Variables

Example correct entries:

```
C:\Users\YOURNAME\AppData\Local\Programs\Python\Launcher\
C:\Users\YOURNAME\AppData\Local\Programs\Python\Python311\Scripts\
C:\Users\YOURNAME\AppData\Local\Programs\Python\Python311\
```

If that doesn’t work, scream into a bucket.

---

## Installing Git

Get Git from [git-scm.com/downloads/win](https://git-scm.com/downloads/win). Default install is fine.

If you're using Chocolatey (spelling: correct), run:

```
choco install git python --version=3.11.9
```

You can find Chocolatey at [https://chocolatey.org](https://chocolatey.org). It's a Windows package manager. Yes, that’s a real thing.

---

## Setting Up Your Working Directory

Make a directory:

```
mkdir \zluda
cd \zluda
```

Yes, it's called `zluda`, and no, you're not using ZLUDA. That’s what mine is called, and now it’s your problem too.

---

## Cloning and Preparing ComfyUI

Clone ComfyUI into a new folder:

```
git clone https://github.com/comfyanonymous/ComfyUI comfy-rock
cd comfy-rock
```

Create a new batch file:

```
notepad install-rock.bat
```

Paste the contents of [`install-rock.bat`](https://gist.github.com/sfinktah/85459b3a9bcf959d6c3ace7e777cb66e#file-install-rock-bat) from that gist.

Run it:

```
install-rock
```

If Git wasn’t found, you're done. Go outside.

---

## Linking Shared Directories

Save time and disk space. Reuse your existing `models`, `input`, `output`, and `users` directories by running:

[link-old-directories.bat](https://gist.github.com/sfinktah/85459b3a9bcf959d6c3ace7e777cb66e#file-link-old-directories-bat)

This makes symbolic links so you’re not re-downloading 80GB of the same crap across five different comfy installs.

---

## Migrating Custom Nodes

You *could* link `custom_nodes` too, but that’s just asking for pain.

Instead:

1. Copy everything manually (except `__pycache__`)
2. Run this script from inside `custom_nodes`:

[fix-copied-custom-nodes.sh](https://gist.github.com/sfinktah/85459b3a9bcf959d6c3ace7e777cb66e#file-fix-copied-custom-nodes-sh)

This removes compiled files and re-runs `requirements.txt` as needed.

If a node causes trouble, just delete it and reinstall via the ComfyUI Node Manager.

---

## ComfyUI Startup Script

Use this batch file to launch ComfyUI:

[comfy-rock.bat](https://gist.github.com/sfinktah/85459b3a9bcf959d6c3ace7e777cb66e#file-comfy-rock-bat)

It supports extra arguments. So run it like this:

```
comfy-rock --normalvram
```

Don’t mess with `--attention` because aotriton is baked in. If you’re curious: [ROCm aotriton](https://github.com/ROCm/aotriton)

---

## Installing WAN2GP

Follow the instructions at [WAN2GP](https://github.com/deepbeepmeep/Wan2GP/blob/main/docs/INSTALLATION.md), but **do not** install their torch packages.

Instead, run this:

```
pip install ^
    https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torch-2.7.0a0+rocm_git3f903c3-cp311-cp311-win_amd64.whl ^
    https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torchaudio-2.7.0a0+52638ef-cp311-cp311-win_amd64.whl ^
    https://github.com/scottt/rocm-TheRock/releases/download/v6.5.0rc-pytorch-gfx110x/torchvision-0.22.0+9eb57cd-cp311-cp311-win_amd64.whl
```

Yes, those links may go stale. Go update them yourself from [the main release page](https://github.com/scottt/rocm-TheRock/releases).

---

## Performance Notes and Bugs

* `aotriton` backend is about **10% faster** than ZLUDA
* CPU clip/text encoding is **glacial**, bring snacks
* DisTorch works, but leaks memory like a faithless ex
* See error like:

```
MIOpen Error: D:/jam/TheRock/ml-libs/MIOpen/src/ocl/convolutionocl.cpp:275: No suitable algorithm was found to execute the required convolution
```

This means: **use VAE Decoding (Tiled)**. Seriously. That one took an entire wasted day to figure out.

---

## Final Thoughts

This whole setup is barely held together with willpower, git, and contempt. But it works. Mostly. If it breaks, you're on your own. If it works, act like you meant it.
