import requests

CLIENT_ID = '37c20107468d46abb7434eca03648d2f'
CLIENT_SECRET = '05713a72c1be4e26a8e8136b4c7f01d4'
AUTH_LINK= "https://accounts.spotify.com/authorize/"
AUTH_URL = 'https://accounts.spotify.com/api/token'

payload={"client_id":"CLIENT_ID","response_type":"code",
         }
auth_response=requests.post(AUTH_URL,{
    'grant_type': 'client_credentials',
    'client_id': CLIENT_ID,
    'client_secret': CLIENT_SECRET
})

auth_response_data = auth_response.content
print(auth_response_data)
# save the access token
access_token = auth_response_data['access_token']
print(access_token)