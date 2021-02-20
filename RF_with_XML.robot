*** Settings ***
Library     XML
Library     Collections
Library     RequestsLibrary
Library     json

*** Variables ***
${Client}   37c20107468d46abb7434eca03648d2f
${Secret}   05713a72c1be4e26a8e8136b4c7f01d4
@{list_of_artists}

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
            Log to console  ${list_of_artists}
            Log to console  ******
    END
    should contain      ${list_of_artists}      Guns N' Roses

Verify the Spotify API returns the correct artist given a song URI code
