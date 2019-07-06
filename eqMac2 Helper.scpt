# Add an option to display notifications for every song change

#Change me to enable notifications:
notifications = True

#Change me to interrupt mid song
interruptions = True

repeat
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
	if notifications then
		display notification "is now playing on Spotify" with title track_name subtitle track_artist
	end if
	delay (track_duration - seconds_played)
	
	# Check here if the current song playing is still the one that was playing before the delay, and if true, restart eqMac2. If not, either wait
	# until the song is finished, or interrupt the song and restart eqMac2 (depends on interruptions variable).

	if application "eqMac2" is running then
		if notifications then:
			display notification "restarting eqMac2…" with title "eqMac2 Helper"
		end if
		tell application "Spotify" to pause
		tell application "eqMac2" to quit
		delay 0.5
		tell application "eqMac2" to activate
		tell application "Spotify" to play
	else
		if notifications then:
			display notification "starting eqMac2…" with title "eqMac2 Helper"
		end if
		tell application "eqMac2" to quit
		tell application "eqMac2" to activate
		tell application "Spotify" to play
	end if
end repeat