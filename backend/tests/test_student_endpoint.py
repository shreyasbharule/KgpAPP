def test_student_can_fetch_own_profile(client):
    login = client.post(
        '/api/v1/auth/login',
        json={'email': 'student@test.edu', 'password': 'StudentPass123!'},
    )
    token = login.json()['access_token']

    response = client.get(
        '/api/v1/student/me',
        headers={'Authorization': f'Bearer {token}'},
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload['full_name'] == 'Student User'
    assert payload['roll_number'] == '20CS10001'
