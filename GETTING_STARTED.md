# GETTING_STARTED.md — Hoardseeker

> Your literal, step-by-step guide from "nothing installed" to "ready to start building with Claude Code."
> Read this once start to finish before doing anything. Then start at Step 1 and work through.
> Estimated time: 1-2 hours, depending on download speeds and how many of these tools you already have.

---

## Before you start: a few things to know

### Your operating system

This guide covers **macOS** and **Windows 10/11**. If you're on Linux, you probably don't need this guide.

When the guide says something like "open Terminal," that means:
- **macOS**: press `⌘ + Space`, type "Terminal," press Enter
- **Windows**: press the Windows key, type "PowerShell," press Enter (use PowerShell, not Command Prompt)

### Your computer

You'll need a computer that can run Godot 4. Minimum specs are modest:
- **macOS**: Big Sur (11) or newer
- **Windows**: 10 or 11
- **RAM**: 8 GB minimum, 16 GB recommended
- **Storage**: At least 20 GB free
- A modern-ish CPU (anything from the last 5-7 years)

If your laptop is older than 2018 or has 4 GB of RAM, this will be painful. Consider upgrading before you start.

### Bootstrap mode flag (important)

You picked **bootstrap mode (<$5k total budget)**. This means the project plan needs to be realigned in two ways before Claude Code starts writing code:

1. **Visual direction will likely shift away from 2D painted realism** toward pixel art, stylized line art, or another style achievable without contracted illustrators. We'll have this conversation as your first task in Claude Code.
2. **Audio plan will rely on royalty-free music + free SFX libraries**, with maybe one or two paid one-off pieces.

These are normal, healthy adjustments. Many breakout solo dev games (Stardew Valley, Undertale, Vampire Survivors) shipped on bootstrap budgets with appropriate art direction. Your first Claude Code conversation will lock in the new direction.

### What you do *not* need to know

You do not need to know:
- How to write code
- How Git works in detail
- What "the terminal" is for
- Anything about programming concepts

You do need to know:
- How to follow instructions literally
- How to copy and paste
- How to make a sandwich (just kidding, but seriously, take breaks)

If something doesn't work, the answer is almost always: **screenshot the error, paste it into Claude Code, ask "what does this mean and what should I do?"** Don't try to debug yourself.

---

## Step 1: Create accounts (15 minutes)

You'll need accounts on a few services. Create them now so you have them ready.

### 1.1 GitHub account

GitHub is where your project's code lives in the cloud. It's your backup, your version history, and (eventually) where collaborators see your work.

1. Go to **github.com** in your browser.
2. Click **"Sign up"** in the top right.
3. Use a personal email (not work).
4. Pick a username you wouldn't be embarrassed by — it'll be visible. Lowercase letters and numbers work best.
5. Verify your email.
6. **Choose the free plan.** You don't need anything paid.

**Save somewhere safe:**
- Your GitHub username
- The email you signed up with
- The password (use a password manager if possible)

### 1.2 Anthropic account (for Claude Code)

If you already have a Claude.ai account, this is the same login.

1. Go to **claude.ai** if you don't have an account.
2. Sign up.
3. You'll need a **Claude paid plan** to use Claude Code effectively. Check current pricing at anthropic.com.

### 1.3 Steam account (skip if you have one)

You won't use Steam right away, but you'll need a Steam developer account around month 5. Get the basic Steam account now.

1. Go to **store.steampowered.com**.
2. Click **"Login"** in the top right, then **"Join Steam."**
3. Free account.

### 1.4 (Optional but recommended) A password manager

If you don't already use one, install **1Password**, **Bitwarden** (free), or **Apple Keychain** (built into macOS). You're about to create a lot of accounts. Keep them organized.

---

## Step 2: Install software (45-60 minutes)

Install these in this order. Each one is free.

### 2.1 Visual Studio Code (your code editor)

This is the program where you'll see your project's files. Even though you won't write code, you'll have it open often.

**macOS:**
1. Go to **code.visualstudio.com**.
2. Click the big blue **"Download for macOS"** button.
3. Open the downloaded `.zip` file. A "Visual Studio Code" app appears.
4. Drag it to your **Applications** folder.
5. Open Applications and double-click Visual Studio Code. Approve any "downloaded from internet" warning.

**Windows:**
1. Go to **code.visualstudio.com**.
2. Click **"Download for Windows."**
3. Run the installer. Accept defaults, but make sure these checkboxes are checked:
   - "Add 'Open with Code' action to Windows Explorer file context menu"
   - "Add 'Open with Code' action to Windows Explorer directory context menu"
   - "Register Code as an editor for supported file types"
   - "Add to PATH"
4. Click through. Launch VS Code.

**Test it:** VS Code opens. You see a welcome screen. ✅

### 2.2 Git (the version control tool)

Git is what backs up your code to GitHub. Even if you never type a `git` command yourself (Claude Code will do that), you need it installed.

**macOS:**
1. Open **Terminal**.
2. Type `git --version` and press Enter.
3. If it shows a version (like `git version 2.39.x`), you have it. ✅ Skip to 2.3.
4. If it says "command not found" or prompts you to install developer tools, click **"Install."** Wait 5-10 minutes.
5. After installation, type `git --version` again to confirm.

**Windows:**
1. Go to **git-scm.com/download/win**.
2. Download the 64-bit Standalone Installer.
3. Run it. **Important options on each screen:**
   - "Select Components" — accept defaults.
   - "Choosing the default editor" — pick **"Visual Studio Code"** from the dropdown.
   - "Adjusting your PATH environment" — pick **"Git from the command line and also from 3rd-party software."**
   - "Choosing HTTPS transport backend" — accept default.
   - "Configuring the line ending conversions" — pick **"Checkout Windows-style, commit Unix-style line endings."**
   - "Configuring the terminal emulator" — pick **"Use Windows' default console window"** (simpler) or MinTTY (also fine).
   - Everything else: defaults.
4. Finish installer.
5. Open PowerShell, type `git --version`, press Enter. Should show a version.

**Tell Git who you are** (one-time setup):

In Terminal (Mac) or PowerShell (Windows), type these two commands, replacing the values with your real info:

```
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"
```

Use the same email you used for GitHub.

### 2.3 Node.js (required by Claude Code)

Claude Code is a Node.js application, so we need Node installed.

**macOS:**
1. Go to **nodejs.org**.
2. Download the **LTS** version (the one labeled "Recommended For Most Users").
3. Run the `.pkg` installer. Click through with defaults.
4. Open Terminal, type `node --version`, press Enter. You should see a version (like `v20.x.x`). ✅

**Windows:**
1. Go to **nodejs.org**.
2. Download the **LTS** version (Windows Installer, 64-bit).
3. Run the `.msi` installer. Accept defaults. **Make sure** "Add to PATH" is checked.
4. Restart PowerShell (close it and reopen).
5. Type `node --version`, press Enter. You should see a version.

### 2.4 Godot 4 (the game engine)

This is the program that will run your game.

1. Go to **godotengine.org/download**.
2. Download **Godot Engine 4.x** (the **Standard** version, not the .NET version).
3. **macOS**: open the `.dmg`, drag Godot to Applications, open it.
4. **Windows**: extract the `.zip` file. Move the `Godot_v4.x.x-stable_win64.exe` file somewhere stable like `C:\Godot\`. Double-click to run.

When Godot opens, you'll see a "Project Manager" window with a list of projects (empty for now). Close Godot for now — we'll come back to it.

### 2.5 Claude Code

1. Open Terminal (Mac) or PowerShell (Windows).
2. Type this command and press Enter:
   ```
   npm install -g @anthropic-ai/claude-code
   ```
3. Wait for the install to finish (1-3 minutes).
4. Type `claude --version` and press Enter. You should see a version. ✅

If it says "command not found" after install, close and reopen the terminal, try again.

---

## Step 3: Create your project repository (15 minutes)

This is where your project will live, both on your computer and on GitHub.

### 3.1 Create the repository on GitHub

1. Log into **github.com**.
2. Click the **+** icon in the top right, then **"New repository."**
3. Repository name: **`hoardseeker`** (lowercase).
4. Description: *"D&D-inspired roguelike deckbuilder, solo + duo with ranked leaderboards."*
5. Set to **Private** (you can make it public later).
6. Check **"Add a README file."**
7. **"Add .gitignore"** dropdown: pick **`Godot`** from the list.
8. **"Choose a license"**: skip for now (you can add later).
9. Click **"Create repository."**

You now have an empty repo on GitHub. ✅

### 3.2 Pick a folder for your project on your computer

Choose a place to store your project. Recommendations:

- **macOS**: `~/Documents/dev/hoardseeker` or `~/Projects/hoardseeker`
- **Windows**: `C:\Dev\hoardseeker` or `C:\Users\YourName\Documents\dev\hoardseeker`

Don't put it in a synced cloud folder (Dropbox, OneDrive, iCloud). Git and cloud sync don't always play well together.

### 3.3 Clone the repo to your computer

"Clone" means "make a copy of the GitHub repo on my local computer."

1. On the GitHub page for your new repo, click the green **"Code"** button.
2. In the popup, select the **HTTPS** tab.
3. Click the copy icon. The URL looks like `https://github.com/yourname/hoardseeker.git`.
4. Open Terminal (Mac) or PowerShell (Windows).
5. Navigate to where you want the project. Examples:
   - macOS: `cd ~/Documents` (then maybe `mkdir dev && cd dev`)
   - Windows: `cd C:\` (then maybe `mkdir Dev && cd Dev`)
6. Type:
   ```
   git clone <PASTE THE URL YOU COPIED>
   ```
   Hit Enter. After a moment, a folder called `hoardseeker` is created.
7. Enter the folder: `cd hoardseeker`
8. Type `ls` (Mac) or `dir` (Windows). You should see `README.md` and `.gitignore`. ✅

### 3.4 Open the project in VS Code

1. With your terminal still in the `hoardseeker` folder, type:
   ```
   code .
   ```
   (That's "code" followed by a space and a period.)
2. VS Code opens with your project. You'll see `README.md` and `.gitignore` in the left sidebar.

If `code .` doesn't work on Mac, open VS Code first, press `⇧⌘P`, type "Shell Command: Install 'code' command in PATH," select it, then try again.

---

## Step 4: Add the design docs (5 minutes)

You have 11 .md files from our planning conversation. Time to put them in the project.

1. In VS Code, in the left sidebar, right-click on the `HOARDSEEKER` folder name (the project root).
2. Click **"New Folder."** Name it `docs`.
3. Drag all 11 .md files (CLAUDE.md, VIBE_CODING.md, RESILIENCE.md, VISION.md, ARCHITECTURE.md, VERTICAL_SLICE.md, FULL_VISION.md, CONTENT.md, MULTIPLAYER.md, ROADMAP.md, DECISIONS.md) into the `docs` folder in VS Code.

Wait — there's actually one important move to make: **CLAUDE.md should live at the project root, not in `docs/`.** Claude Code reads `CLAUDE.md` from the project root automatically.

So:
- `hoardseeker/CLAUDE.md` (at the root)
- `hoardseeker/docs/VIBE_CODING.md`
- `hoardseeker/docs/RESILIENCE.md`
- `hoardseeker/docs/VISION.md`
- ... (the rest in docs/)

Edit `CLAUDE.md` to update the file paths it references. Open it in VS Code and find every reference like `VIBE_CODING.md` and change it to `docs/VIBE_CODING.md`. (Or: ask Claude Code to do this on its first run.)

### 4.1 Push the docs to GitHub

Once the docs are in place:

1. Open Terminal (Mac) or PowerShell (Windows). Make sure you're in the `hoardseeker` folder.
2. Type these commands one at a time:
   ```
   git add .
   ```
   (This stages all the new files for commit.)
   
   ```
   git commit -m "Initial design docs"
   ```
   (This commits the changes locally.)
   
   ```
   git push
   ```
   (This sends them to GitHub.)
3. Refresh your GitHub repo page in the browser. You should see your `docs/` folder with all the .md files. ✅

You just made your first commit. Welcome to version control.

---

## Step 5: First Claude Code session (15 minutes)

This is the moment you swap from this conversation to Claude Code.

### 5.1 Start Claude Code

1. Open Terminal (Mac) or PowerShell (Windows).
2. Navigate to your project folder:
   ```
   cd path/to/hoardseeker
   ```
3. Type:
   ```
   claude
   ```
   Press Enter.
4. The first time, it'll prompt you to log in. Follow the prompts (it'll open a browser for authentication).

You'll see a Claude Code prompt waiting for your message.

### 5.2 The first message

Copy and paste this exact message into Claude Code:

```
Read the docs in this project starting with CLAUDE.md (in the root), 
then read all files in docs/ in this order:

1. docs/VIBE_CODING.md
2. docs/RESILIENCE.md  
3. docs/VISION.md
4. docs/ARCHITECTURE.md
5. docs/VERTICAL_SLICE.md
6. docs/FULL_VISION.md
7. docs/CONTENT.md
8. docs/MULTIPLAYER.md
9. docs/ROADMAP.md
10. docs/DECISIONS.md

Do NOT write any code yet. After reading, do three things:

1. Summarize back to me what you understand about the project in 5 sentences.
2. Tell me what you understand about how I prefer to work (from VIBE_CODING.md and RESILIENCE.md).
3. Wait for me to tell you what we're tackling first.

I am a non-technical user. Always propose plans in plain English before 
writing code. Always confirm before irreversible actions. We are in 
bootstrap budget mode (<$5k total).
```

Wait for Claude Code to read everything and respond. This may take a minute.

### 5.3 Verify it understood

Read Claude Code's summary carefully. Things it should mention:

- D&D-inspired roguelike deckbuilder, Godot 4, GDScript
- Solo + duo modes with ranked leaderboards (per VISION.md)
- Vertical slice = Fighter + Crypt + Lich King in Human race only
- Determinism / command pattern / event sourcing architecture
- Daily commit minimum, 40-hour cap, weekly day off
- The non-technical user posture: plan in plain English, confirm before irreversible, branches not main

If anything seems off, say so directly: *"You missed [thing]. Re-read [file] and try again."*

### 5.4 The first real task: bootstrap mode realignment

When Claude Code is ready, your next message:

```
Our first task: realign the design for bootstrap budget mode (<$5k total).

The current docs assume a 2D painted realism art direction with 216 launch
portraits, contracted illustrator, contracted composer, contracted voice 
actor. This is not feasible on bootstrap budget.

I need your honest analysis of:

1. What art direction is achievable for one non-technical solo dev with 
AI assistance and <$5k? Trade-offs of pixel art vs. stylized line art vs.
other options.

2. What audio direction is achievable? Royalty-free music sources, 
narration options if we can't afford a voice actor.

3. Which design docs need updating to reflect this, and what specifically 
changes in each.

Walk me through your thinking. Do NOT update the docs yet — propose, then 
we'll discuss, then update.
```

This kicks off the first real design conversation in Claude Code. From there, you direct.

---

## Step 6: What "done with setup" looks like

You've successfully completed setup when all of these are true:

- [ ] GitHub account created, you can log in.
- [ ] VS Code installed and opens cleanly.
- [ ] Git installed (`git --version` shows a version).
- [ ] Node.js installed (`node --version` shows a version).
- [ ] Godot 4 installed and opens to the Project Manager.
- [ ] Claude Code installed (`claude --version` shows a version).
- [ ] `hoardseeker` repo created on GitHub.
- [ ] Repo cloned to your computer.
- [ ] All 11 .md docs are in the project (CLAUDE.md at root, others in docs/).
- [ ] Docs pushed to GitHub (visible on github.com).
- [ ] First Claude Code session completed, AI summarized the project back accurately.
- [ ] First task started: bootstrap mode realignment discussion.

---

## Common problems and fixes

### "Command not found"

The terminal can't find the program you're trying to run. Causes:

- Software didn't install correctly. Try installing again.
- You need to restart your terminal. Close it, open a new one, try again.
- On Mac, you may need to allow the program in System Preferences → Privacy & Security.

### "Permission denied"

You're trying to write to a folder you don't have permission to. Move your project to your home/user folder, not a system folder.

### Git asks for username/password every time

Set up GitHub authentication once:

```
gh auth login
```

(Requires the GitHub CLI: `brew install gh` on Mac, or download from cli.github.com.)

Or use **GitHub Desktop** (a graphical tool) instead of command-line Git: desktop.github.com.

### VS Code "code" command doesn't work on Mac

Open VS Code, press `⇧⌘P`, type "Shell Command: Install 'code' command in PATH."

### Claude Code is slow / timing out

Try restarting it. If still slow, check your internet connection. Claude Code makes a lot of API calls.

### Godot won't open ("damaged" warning on Mac)

Right-click Godot in Applications → "Open" → "Open" (the Open button in the warning dialog). After the first time, it opens normally.

### "I don't know what just happened"

This is the right reaction more often than you'd think. Your move:

1. Take a screenshot.
2. Paste it into Claude Code with the message: *"Something just happened that I don't understand. Here's the screenshot. What does this mean?"*
3. Don't try to fix it yourself.

---

## What to keep nearby for the first month

Bookmark these:

- This file (GETTING_STARTED.md), so you can re-read it.
- Your GitHub repo URL.
- VIBE_CODING.md and RESILIENCE.md, so you can re-read them weekly.
- The decision calendar at the bottom of VIBE_CODING.md.

Print and tape somewhere visible:
- The decision calendar
- The "permission slips" page from RESILIENCE.md
- Your weekly day off (Sunday by default)

---

## Time check

If you've done all the steps above, you've spent about 1.5-2 hours. You now have:

- A fully set-up dev environment
- A live GitHub repository with all your design docs
- An active Claude Code session
- A first real task underway (bootstrap mode realignment)

**That's day 1 done.** You have not written any code, and that is correct. The next session will produce the first code, but only after the design conversation about bootstrap mode is complete.

Take a break. Make a coffee. Come back when you're ready for the realignment conversation in Claude Code.

If something is unclear about this guide or any step failed, message me back here in this conversation before continuing. We can fix the doc and try again.
