<div align="center">
  <img width="1920" alt="image" src="https://github.com/user-attachments/assets/fedfd7f0-2d77-433b-b5fc-95d01fcbfe5f" /> 

  <br>
  
  <em> _beautiful_ </em> <img align="absmiddle" width="45" alt="maxresdefault-removebg-preview" src="https://github.com/user-attachments/assets/10990b62-8776-46ff-8b39-a8fedbf1395c" />

  
</div>

<br>
<br>
<br>

<div align="center">

### windows terminal + nvim background

<sub>for when neovim needs to feel a little less empty</sub>

<br>

<img width="1920" alt="nvim_pc" src="https://github.com/user-attachments/assets/d1ff14b7-3842-4a16-bec5-da3bc995ecdc" />

</div>

<br>

open your Windows Terminal `settings.json`:

```txt
Windows Terminal → dropdown arrow OR ctrl+, → Settings → Open JSON file
```

place the profile inside:

```jsonc
"profiles": {
  "list": [
    // put the Neovim profile here
  ]
}
```

example:

```jsonc
{
  "name": "Neovim",
  "commandline": "nvim.exe",
  "guid": "{replace-with-your-own-guid}",
  "hidden": false,

  "backgroundImage": "C:\\Users\\yourname\\Pictures\\wallpapers\\example.png",
  "backgroundImageOpacity": 0.6,
  "backgroundImageStretchMode": "uniformToFill",

  "opacity": 90,
  "useAcrylic": false,
  "padding": "0"
}
```

tiny notes:

```txt
backgroundImage             image shown behind nvim
backgroundImageOpacity      how visible the image is
backgroundImageStretchMode  fills the terminal nicely
opacity                     opacity of the terminal window
useAcrylic                  blur/transparency through the desktop
padding                     removes extra terminal spacing
```

launch with:

```powershell
wt -p "Neovim"
```

or just open the **Neovim** profile/application from Windows Terminal.

<div align="center">
  <sub>make sure your nvim colorscheme has a transparent background too</sub>
</div>
