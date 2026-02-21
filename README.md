# Valheim Game Libs Nuget Creator

Creates nugets with stripped and publicized libraries for Valheim modding.

When there is a new game version, you must update this package manager.

## Usage

- Linux Host + Windows VM Quick Start:
    - On Linux, download Valheim Windows Edition:
        - Navigate to `steam://open/console`
        - Run: `@sSteamCmdForcePlatformType windows`
        - Force reinstall Valheim
        - Verify there are `.exe` files in the game path
        - Copy those to the Windows VM (Syncthing, shared folder, etc...)
        - Start publicizing: 
            - Drag the `.exe` onto the `.bat`...

### Nuget account

- Go to [nuget.org](https://nuget.org/).
- Either log in, or create a new account.
- [Create a new API key](https://www.nuget.org/account/apikeys) with permissions to push new packages.

### Prepare your repository

- Fork this repository
- Add a `Repository` secret called `NUGET_KEY` to this repository. Give it the value of the API key you created earlier.
- Update the repository's name. This will be used as your Nuget ID, so it can't clash with another nuget package on [nuget.org](https://nuget.org/).
- Update the repository's description. This will be used as the nuget's description too.

### Generate the stripped libraries

- Ensure that your game files are completely Vanilla.
- Drag the game's `.exe` onto `strip-assembiles.bat`.
- Dlls are stripped, publicized, and placed in `package\lib`.

### Updating the Nuget

- Inside `./package`, edit the `.nuspec` file, make `<version>` match the game version.
- Push to master.
- Navigate to your workflows and run this tool to upload to Nuget.

### Publicized assemblies

All Valheim and Unity `.dlls` are publicized. To publicize other dlls, edit `strip-assemblies.bat` and add the dll names to the `toPublicize` variable.
