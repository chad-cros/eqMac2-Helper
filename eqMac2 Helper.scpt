# option to display notifications for every song change
set answer to choose from list {"Yes", "No"} with prompt "Turn on notifications?" default items {"No"}
set notifications to answer is {"Yes"}

delay 0.5

# option to interrupt midsong to restart eqMac
set answer to choose from list {"Yes", "No"} with prompt "Interrupt mid song?" default items {"Yes"}
set interrupts to answer is {"Yes"}

delay 0.5

# intelligently choose which player to control based on which one is actively playing music 
#	when script is started
set spotify_playing to false
set itunes_playing to false
set current_player to "Spotify"
if application "Spotify" is running
	tell application "Spotify"
		if player state is playing then
			set spotify_playing to true
		end if
	end tell
end if
if application "iTunes" is running then
	tell application "iTunes"
		if player state is playing then
			set itunes_playing to true
		end if
	end tell
end if
if ( spotify_playing and itunes_playing ) or not ( spotify_playing and itunes_playing ) then
	set answer to choose from list {"Spotify", "iTunes"} with prompt "Choose your music player." default items {"Spotify"}
	if answer is {"Spotify"}
		set current_player to "Spotify"
	else
		set current_player to "iTunes"
	end if
else
	if spotify_playing and not itunes_playing then
		set current_player to "Spotify"
	end if
	if itunes_playing and not spotify_playing then
		set current_player to "iTunes"
	end if
end if

if not application "eqMac2" is running then
	tell application "eqMac2" to activate
end if

# Tell user that eqMacHelper is running with the given config
delay 1
display notification "Notifications: " & notifications & "\nInterruptions: " & interrupts with title "Now starting eqMac Helper..." subtitle "github.com/chad-cros/eqMac2-Helper"

#Loop to continuously reset eqMac here
repeat
	#--
	# If Spotify/iTunes is opened, then set the track_name / artist / etc here, else kill the script
	#--
	if current_player is "Spotify" then
		if application "Spotify" is running then
			tell application "Spotify"
				set track_artist to artist of current track
				set track_name to name of current track
				set track_duration to round ((duration of current track) / 1000) rounding up
				set seconds_played to round (player position / 1) rounding down
			end tell
		else
			exit repeat
		end if
	else
		if application "iTunes" is running then
			tell application "iTunes"
				set track_artist to artist of current track
				set track_name to name of current track
				set track_duration to round ((duration of current track) / 1000) rounding up
				set seconds_played to round (player position / 1) rounding down
			end tell
		else
			exit repeat
		end if
	end if


	#--
	# Display notification of current track if notificaitons are on
	#--
	if notifications then
		display notification "is now playing on " & current_player with title track_name subtitle track_artist
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
	# This handles the case when the song should be done playing. It again checks if Spotify/iTunes is running, and exits the loop if it's not.
	#--
	if current_player is "Spotify" then
		if application "Spotify" is running then
			tell application "Spotify"
				if not player state is playing then
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
				if interrupts or (track_duration - seconds_played < 0.5) then
					delay 0.1
				else
					# do shell script ("caffeinate -dit " & (track_duration - seconds_played + 1))
					delay (track_duration - seconds_played)
				end if
			end if
		else
			exit repeat
		end if
	else
		if application "iTunes" is running then
			tell application "iTunes"
				if not player state is playing then
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
				if interrupts or (track_duration - seconds_played < 0.5) then
					delay 0.1
				else
					# do shell script ("caffeinate -dit " & (track_duration - seconds_played + 1))
					delay (track_duration - seconds_played)
				end if
			end if
		else
			exit repeat
		end if
	end if

	#--
	# Restarts eqMac if it was running, launches it if it wasn't
	#--
	if application "eqMac2" is running then
		if notifications then
			display notification "restarting eqMac2…" with title "eqMac2 Helper"
		end if
		if current_player is "Spotify"
			tell application "Spotify" to pause
			tell application "eqMac2" to quit
			delay 0.5
			tell application "eqMac2" to activate
			tell application "Spotify" to play
		else
			tell application "Spotify" to pause
			tell application "eqMac2" to quit
			delay 0.5
			tell application "eqMac2" to activate
			tell application "Spotify" to play
		end if
	else
		if notifications then
			display notification "starting eqMac2…" with title "eqMac2 Helper"
		end if
		if current_player is "Spotify"
			tell application "Spotify" to pause
			tell application "eqMac2" to activate
			tell application "Spotify" to play
		else
			tell application "iTunes" to pause
			tell application "eqMac2" to activate
			tell application "iTunes" to play
		end if
	end if
end repeat

tell application "eqMac2" to quit
