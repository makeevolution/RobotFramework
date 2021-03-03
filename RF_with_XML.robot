*** Settings ***
Library     XML
Library     Collections
Library     RequestsLibrary
Library     json
Library     SeleniumLibrary
Library     OperatingSystem

*** Variables ***
${Client}   37c20107468d46abb7434eca03648d2f
${Secret}   05713a72c1be4e26a8e8136b4c7f01d4
${user_ID}  makeevolution
${token}    BQDNTCHYqxxJ9aEiacIWd879aWgBxU9D7xkxh2juB-UfTNfGvr7dDN7E8lABLbEDMKGfAe8NmuwFf8nFUNrr8wr1dJnKrcqdCLCoh-GEC9Wz-8vBTO6NpY1_ywySSey4XiiBYkrcEgUyq6Nu0cgxpv6ykM7i5BbGfaVCZDaLVQV_i-ph0PDsYDA7tlrI-t6Ipli2NuRleuUc0l8gsHsWA14Vt63rAOuapVSUGcWUPzISZkQ6iUiy0ZuK2XyKgb_CmNWfqCDKX_cWNgjYm8L2M173jKKA
@{list_of_artists}

*** Keywords ***
Setup chromedriver
  Set Environment Variable  webdriver.chrome.driver  C:/Users/aldo-/OneDrive/job/RobotFramework/required_webdrivers/chromedriver.exe
*** Test Cases ***

Verify /authorize endpoint of Spotify works given a valid client ID
    [Tags]  get
    Create Session      spotify             https://accounts.spotify.com/authorize     disable_warnings=1
    &{params}=          Create Dictionary   client_id=${Client} response_type=code show_dialog=false
    ${resp}=            Get On session      spotify                                     /                                       params=${params}

    Should Be Equal As Strings      ${resp.status_code}       200

Verify the Spotify API returns the correct artist given a song URI code
    # This code checks if, given a song in Spotify application that corresponds to an artist and an album,
    # the Spotify API also contains the song and refers to the same artist and album

    # First we get access token
    Create Session      spotify             https://accounts.spotify.com/api     disable_warnings=1
    Create Session      spotifyGETDATA      https://api.spotify.com/v1          disable_warnings=1
    &{data}=          Create Dictionary   client_secret=${Secret}  client_id=${Client}  grant_type=client_credentials  response_type=code
    # Then we do GET request with access token and a track_id assigned to a song
    ${resp}=          Post On Session   spotify     /token      data=${data}
    ${track_id}=     Set Variable    7o2CTH4ctstm8TNelqjb51
    ${bearer}=  Set Variable    Bearer ${resp.json()["access_token"]}
    ${headers}=     Create Dictionary   Authorization=${bearer}
    ${resp}=          Get On Session   spotifyGETDATA     /tracks/${track_id}   headers=${headers}
    # And finally check if the track is sang by the correct artist
    FOR     ${artist}   IN      @{resp.json()["artists"]}
            Append to list       ${list_of_artists}    ${artist["name"]}
            #Log to console  ${list_of_artists}
            #Log to console  ******
    END
    should contain      ${list_of_artists}      Guns N' Roses

Verify under construction
    Create Session      spotify             https://accounts.spotify.com/authorize     disable_warnings=1
    &{params}=          Create Dictionary   client_id=${Client} response_type=code show_dialog=false redirect_uri=https://aldohasibuan.com scope=user-read-recently-played
    ${resp}=            Get On session      spotify                                     /                                       params=${params}

#Check create playlist
#    Create Session      spotify     https://api.spotify.com/v1/users/${user_ID}
#    &{data}=          Create Dictionary   name=test  description=test
#    &{headers}=       Create dictionary   Content-Type=application/json  Authorization=Bearer ${token}
#    ${resp}=          Post On Session     spotify   /playlists    json=${data}    headers=${headers}

Check add song
    Create Session      spotify     https://api.spotify.com/v1/playlists/4Dzz41xu8Ip8xHrvZ6rPWQ
    &{headers}=       Create dictionary   Authorization=Bearer ${token} Content-Type: application/json
    ${resp}=          Post On Session     spotify   /tracks?uris\=spotify%3Atrack%3A0nsL0AalAUFNCi7DYhnihQ   headers=${headers}
    #log to console  ${resp}

Get playlist ID
    Create Session      spotifyGetPlaylistList     https://api.spotify.com/v1/makeevolution/playlists
    &{headers}=       Create dictionary   Authorization=Bearer ${token} Content-Type: application/json
    ${resp}=          Get On Session     spotify   /   headers=${headers}
    log to console  ${resp.json()["id"]}

Check search song
    ${song_name}=   Set Variable    Smells Like Teen Spirit
    ${artist}=  Set Variable    Nirvana
    &{headers}=       Create dictionary   Authorization=Bearer ${token} Content-Type: application/json
    Create Session      spotifySearchSong      https://api.spotify.com/v1          disable_warnings=1
    # Then we do GET request with access token and a track_id assigned to a song
    ${resp}=    Get On Session      spotifySearchSong      /search?q\=track:${song_name}%20artist:${artist}&type\=track&offset\=0&limit\=20     headers=${headers}
    #log to console   ${resp.json()["tracks"]["items"][0]["id"]}


