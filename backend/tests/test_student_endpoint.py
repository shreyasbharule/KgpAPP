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


def test_student_can_fetch_own_grades_and_timetable(client):
    login = client.post('/api/v1/auth/login', json={'email': 'student@test.edu', 'password': 'StudentPass123!'})
    token = login.json()['access_token']

    grades_response = client.get('/api/v1/student/me/grades', headers={'Authorization': f'Bearer {token}'})
    timetable_response = client.get('/api/v1/student/me/timetable', headers={'Authorization': f'Bearer {token}'})

    assert grades_response.status_code == 200
    assert timetable_response.status_code == 200
    assert 'grades' in grades_response.json()
    assert 'entries' in timetable_response.json()
