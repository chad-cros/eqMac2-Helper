# option to display notifications for every song change

set answer to choose from list {"Yes", "No"} with prompt "Turn on notifications?" default items {"No"}

set notifications to answer is {"Yes"}

delay 1

# option to interrupt midsong to restart eqMac

set answer to choose from list {"Yes", "No"} with prompt "Interrupt mid song?" default items {"Yes"}

set interrupts to answer is {"Yes"}

# Tell user that eqMacHelper is running with the given config
delay 1
display notification "Notifications: " & notifications & "\nInterruptions: " & interrupts with title "Now starting eqMac Helper..." subtitle "github.com/chad-cros/eqMac2-Helper"

#Loop to continuously reset eqMac here
repeat
	#--
	# If Spotify is opened, then set the track_name / artist / etc here, else kill the script
	#--
	if application "Spotify" is running then
		tell application "Spotify"
			if player state is stopped then
				exit repeat
			else
				set track_artist to artist of current track
				set track_name to name of current track
				set track_duration to round ((duration of current track) / 1000) rounding up
				set seconds_played to round (player position / 1) rounding down
			end if
		end tell
	else
		exit repeat
	end if


	#--
	# Display notification of current track if notificaitons are on
	#--
	if notifications then
		display notification "is now playing on Spotify" with title track_name subtitle track_artist
	end if


	#--
	# Keep mac from sleeping for the duration of the song here
	#	FIXME: This doesn't work
	#--
	# do shell script ("caffeinate -dit " & (track_duration - seconds_played + 1))


	#--
	# Wait until track is finished playing here
	#--
	delay (track_duration - seconds_played)


	#--
	# This handles the case when the song should be done playing. It again checks if spotify is running, and exits the loop if it's not.
	#--
	if application "Spotify" is running then
		tell application "Spotify"
			if player state is stopped then
				exit repeat
			else
				set current_track to name of current track
				set track_duration to round ((duration of current track) / 1000) rounding up
				set seconds_played to round (player position / 1) rounding down
			end if
		end tell
		# -- Check if the song playing is still the same song. If it is, move on to killing eqMac
		# -- If not, check if the user enabled interrupts. If interrupts are enabled, go ahead and restart
		# -- eqMac anyway, else wait until the new song is finished.
		# -- TODO: Implement some sort of continue statement here, rather than a dummy delay.
		if current_track is track_name then
			delay 0.1
		else
			if interrupts then
				delay 0.1
			else
				# do shell script ("caffeinate -dit " & (track_duration - seconds_played + 1))
				delay (track_duration - seconds_played)
			end if
		end if
	end if
	

	#--
	# Restarts eqMac if it was running, launches it if it wasn't
	#--
	if application "eqMac2" is running then
		if notifications then
			display notification "restarting eqMac2…" with title "eqMac2 Helper"
		end if
		tell application "Spotify" to pause
		tell application "eqMac2" to quit
		delay 0.5
		tell application "eqMac2" to activate
		tell application "Spotify" to play
	else
		if notifications then
			display notification "starting eqMac2…" with title "eqMac2 Helper"
		end if
		tell application "Spotify" to pause
		tell application "eqMac2" to activate
		tell application "Spotify" to play
	end if
end repeat
