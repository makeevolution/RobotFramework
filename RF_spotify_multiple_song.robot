*** Settings ***
Library     XML
Library     Collections
Library     RequestsLibrary
Library     json
Library     SeleniumLibrary
Library     OperatingSystem

*** Variables ***
#User ID1123
${user_ID}  makeevolution
#Invalid ID used for test case 2-4 below that should give a fail result
${invalid_ID}   maekevolution
#Supply unique token, request this from Spotify API
${token}    BQAmn606wkt9jQoJWymrgjsjT2uDkxPQzmbS5I_WHF63tJgTTshxoIJ9bV_ny87JQ1qJyhDkljIbVL1wCSlltxey0v4RCa4MGYJj0yCiAsDD5tqRL-WVnTu31-9ciQE1ZkaHldti0nudny6lUlSX1DPS01bxyKIS93U_ACFG6QIIM0yRiRuMhtDDWIExfB0TcGK_RuKx7cOR5O9NncBqiwdc7lPtEw8F9QQT6IuVYzJD17cS_dH6io3odkkYmfwJ_HH4_9fu9V-titpF_cmYDaQvAy6-
#Name of new playlist
${playlist_name}=   RobotFrameworkPlaylist
#Song to be added
${song_name}=   Everlong
${artist}=  Foo Fighters


*** Keywords ***
Create All Endpoints and User supplies their User ID
    #Define all endpoints
    Create Session      spotifyAddNewPlaylist        https://api.spotify.com/v1/users/${user_ID}      disable_warnings=1
    Create Session      spotifyGetPlaylistList       https://api.spotify.com/v1/users/${user_ID}/playlists      disable_warnings=1
    Create Session      spotifySearchSong            https://api.spotify.com/v1          disable_warnings=1

Create All Endpoints and User supplies invalid User ID
    Create Session      spotifyAddNewPlaylist        https://api.spotify.com/v1/users/${invalid_ID}      disable_warnings=1
    Create Session      spotifyGetPlaylistList       https://api.spotify.com/v1/users/${invalid_ID}/playlists      disable_warnings=1
    Create Session      spotifySearchSong            https://api.spotify.com/v1          disable_warnings=1

User supplies corresponding User Token and add new playlist
    &{data}=          Create Dictionary   name=${playlist_name}  description=${playlist_name}
    &{headers}=       Create dictionary   Content-Type=application/json     Authorization=Bearer ${token}
    ${resp}=          Post On Session     spotifyAddNewPlaylist   /playlists    json=${data}    headers=${headers}

User supplies invalid User Token and attempts to add a new playlist
    &{data}=          Create Dictionary   name=${playlist_name}  description=${playlist_name}
    &{headers}=       Create dictionary   Content-Type=application/json     Authorization=Bearer ThisSentenceRepresentsInvalidToken
    ${resp}=          Post On Session     spotifyAddNewPlaylist   /playlists    json=${data}    headers=${headers}

Check that newly added playlist is successfully added
    &{headers}=       Create dictionary   Content-Type=application/json     Authorization=Bearer ${token}
    ${all_playlists}    get on session  spotifyAddNewPlaylist    /playlists     headers=${headers}
    @{list_of_playlists}=   Create List
    FOR     ${i}    IN   @{all_playlists.json()["items"]}
        append to list  ${list_of_playlists}    ${i["name"]}
    END
    Should Contain    ${list_of_playlists}      ${playlist_name}

Get ID of newly added playlist
    &{headers}=       Create dictionary   Authorization=Bearer ${token}     Content-Type=application/json
    ${resp_get_playlist}=   Get On Session     spotifyGetPlaylistList   /   headers=${headers}
    ${playlist_ID}=   Set Variable    ${resp_get_playlist.json()["items"][0]["id"]}
    [RETURN]    ${playlist_ID}

Get ID of song wanted to be added
    &{headers}=       Create dictionary   Authorization=Bearer ${token} Content-Type: application/json
    # We do GET request with access token and a track_id assigned to a song
    ${resp_wanted_song}=    Get On Session      spotifySearchSong      /search?q\=track:${song_name}%20artist:${artist}&type\=track&offset\=0&limit\=20     headers=${headers}
    ${wanted_song}=     Set Variable    ${resp_wanted_song.json()["tracks"]["items"][0]["id"]}
    [RETURN]    ${wanted_song}

Add song to the playlist
    ${playlist_ID}=     Get ID of newly added playlist
    ${wanted_song}=     Get ID of song wanted to be added
    Create Session      spotifyAddSongToPlaylist     https://api.spotify.com/v1/playlists/${playlist_ID}    disable_warnings=1
    &{headers}=       Create dictionary   Authorization=Bearer ${token} Content-Type: application/json
    ${resp}=          Post On Session     spotifyAddSongToPlaylist   /tracks?uris\=spotify%3Atrack%3A${wanted_song}   headers=${headers}

Check that the newly added song is in the playlist
    &{headers}=       Create dictionary   Authorization=Bearer ${token} Content-Type: application/json
    Create Session      spotifyGetSongsInPlaylist     https://api.spotify.com/v1/playlists/${playlist_ID}    disable_warnings=1
    ${resp2}    get on session  spotifyGetSongsInPlaylist    /tracks     headers=${headers}
    @{songs_in_playlist}=   Create List
    FOR     ${i}    IN   @{resp2.json()["items"]}
        append to list  ${songs_in_playlist}    ${i["track"]["name"]}
    END
    should contain  ${songs_in_playlist}    ${song_name}

*** Test Cases ***

Test case 1: A user transverses through all valid states and successfully added new song to new playlist
    Create All Endpoints and User supplies their User ID
    User supplies corresponding User Token and add new playlist
    Check that newly added playlist is successfully added
    Add song to the playlist
    Check that the newly added song is in the playlist

Test case 2: A user supplies valid User ID but supplies non-corresponding User Token
    Create All Endpoints and User supplies their User ID
    User supplies invalid User Token and attempts to add a new playlist

Test case 3: A user supplies invalid User ID but supplies their valid User Token
    Create All Endpoints and User supplies invalid User ID
    User supplies corresponding User Token and add new playlist

Test case 4: A user supplies invalid User ID and supplies invalid User Token
    Create All Endpoints and User supplies invalid User ID
    User supplies invalid User Token and attempts to add a new playlist
