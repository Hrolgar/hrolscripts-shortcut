# HrolScripts Shortcut

HrolScripts is a PowerShell module designed to help automate setting up shortcuts for your projects. It allows users to add shortcuts to frequently visited directories, making navigating your file system quicker and easier. Once a shortcut is added, you can directly navigate to the associated directory using the created function, without having to manually type in the full path.
## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development.

### Prerequisites

List what things you need to install the software and how to install them:

Before you begin, you need to have the following installed:
- [PowerShell](https://aka.ms/powershell-release?tag=stable)

### Installing

To get HrolScripts installed and set up on your local machine, follow these steps:

1. **Clone the repository**

   Start by cloning the `HrolScripts` repository from GitHub to your local machine. Use the following command in your terminal:

    ```bash
    git clone git@github.com:Hrolgar/powershell-shortcuts.git
    ```

2. **Open your PowerShell profile**

   Next, you'll want to add the module to your PowerShell profile. Open your PowerShell profile with the following command:

    ```powershell
    notepad $PROFILE
    ```

3. **Import the HrolScripts module**

   In your Notepad editor, add the following line at the end of your script to import HrolScripts. Make sure to replace "/path/to/module/HrolScripts.psd1" with the actual path to the `HrolScripts.psd1` file in the repository you cloned:

    ````powershell
    Import-Module -Name "/path/to/module/HrolScripts.psd1"
    ````

4. **Save and close your PowerShell profile**

   After adding the `Import-Module` line, save your changes and close your Notepad.

5. **Restart PowerShell**

   This step is crucial. You need to restart your PowerShell terminal to apply the changes you've made to your profile.

6. **Initialize HrolScripts**

   The last step is to initialize `HrolScripts` with the following command:

    ```powershell
    HrolScripts --init
    ```

   Now, `HrolScripts` is installed and set up! You can start adding shortcuts and navigate your file system more conveniently.


### Usage

Detailed instructions for use. For instance:

- `HrolScripts --init` to initialize the module and perform the first-time setup.
- `HrolScripts --add` to add a new shortcut. You will be prompted for the name of the shortcut and the path of the corresponding folder.
- `HrolScripts --help` to show the help message with all available commands.
- `HrolScripts --list` to list all shortcuts.
- `HrolScripts --edit` to edit a shortcut. You will be prompted for the name of the shortcut and the new path of the corresponding folder.
- `HrolScripts --remove` to remove a shortcut. You will be prompted for the name of the shortcut.

If you want to edit the configuration file manually, you can find it at `\User\AppData\Roaming\HrolScripts\hrolconfig.json`.

## Built With

- [PowerShell](https://aka.ms/powershell-release?tag=stable)
- [JetBrains Rider](https://www.jetbrains.com/rider/)

## Contributing

Please read `CONTRIBUTING.md` for details on our code of conduct, and the process for submitting pull requests to us.

## Authors

Helgi Skjortnes - [Hrolgar](https://github.com/Hrolgar)

