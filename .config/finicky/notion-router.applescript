-- Finicky hands Notion links to this applet (built by build-notion-router.sh).
-- Brave can't add a tab to an app window and `--app-id` always opens a new one,
-- so load the link in the open Notion app window's tab instead.

property appId : "ccbmjgahhfbnipmooloebpilggohhpap"

on open location theURL
	tell application "Brave Browser"
		-- App windows are the only ones Brave reports as not closeable.
		set appWins to every window whose closeable is false and URL of active tab contains "notion."
	end tell
	if appWins is {} then
		do shell script "open -na 'Brave Browser' --args --app-id=" & appId & ¬
			" --app-launch-url-for-shortcuts-menu-item=" & quoted form of theURL
	else
		tell application "Brave Browser" to set URL of active tab of (item 1 of appWins) to theURL
		do shell script "open -b com.brave.Browser.app." & appId
	end if
end open location
