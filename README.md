# dns-jumper
dns-jumper find and set fastest dns for mac
# requirements
	1.	Install Homebrew (if you don’t already have it):
Open the Terminal application and run the following command to install Homebrew:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

	2.	Install dig via Homebrew:
Once Homebrew is installed, you can install dig by installing the bind package, which includes dig. Run the following command in Terminal:
brew install bind

# Run dns-jumper
sudo chmod +x dns-jumper.sh
./dns-jumper.sh
