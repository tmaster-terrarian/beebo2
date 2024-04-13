# IMPORTANT INFO ABOUT THE `data/` DIRECTORY
this notice applies to: non-modders, modders, translators, sprite artists, and just about anyone else who's interested in the `data` folder. (which probably includes you!)

## FOR NON-MODDERS:
### If you are not a modder and there is an issue with the game misbehaving or crashing, <ins>**tampering with these files probably wont fix your issue**</ins>. Instead, try a <ins>*clean reinstall*</ins> of the game (you won't lose your save data so no worries).

If you think the issue is being caused by a mod, try contacting that mod's author(s) first before contacting me about it
<br>You can usually pretty easily find a link to their issue tracker or contacts

If your issue continues to persist, file an issue on the Github Repository, at: https://github.com/tmaster-terrarian/beebo2/issues/new

## FOR MODDERS:
While modifying these files directly can give some fun results, it is best practice to create a mod using the provided Lua-based Modding API (it will make integrating other mods much simpler too!)

### Compatibility with UndertaleModTool
It's probably broken! If it isn't, then idk good luck using it cause it's pretty broken on newer versions of the Gamemaker Runtime. The game's current runtime version is `2024.2+`, and the last *stable* version that I can remember UMT supporting was `2022 LTS` (or older) and even then it was really buggy.

### Compatibility with .xdelta Patching
I'd imagine based on how Pizza Tower's `PizzaOven` loader has handled it, it's probably not great for this kind of game. It's also not very fun to only be able to use one mod at a time.

### Gamemaker Build Package Type
Most copies of the game should be in `VM` format. However, I will likely start making `Release` builds in `YYC` format in the future for the sake of performance. This would unfortunately(?) make modding the game via UMT much more difficult, as all of the code for the game (save for the `base` mod) would be obfuscated and packed into the `.exe` file, instead of in the `data.win` file like on `VM` builds.

## FOR DATAMINERS:
It will probably be easier to find stuff on the [Github Repository](https://github.com/tmaster-terrarian/beebo2) :)<br>
I keep no secrets, everything is open source!

---
---
last updated by [bscit](https://github.com/tmaster-terrarian) on April 12th, 2024
