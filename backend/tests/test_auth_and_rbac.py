def test_login_success_returns_bearer_token(client):
    response = client.post(
        '/api/v1/auth/login',
        json={'email': 'admin@test.edu', 'password': 'AdminPass123!'},
    )

    assert response.status_code == 200
    data = response.json()
    assert data['token_type'] == 'bearer'
    assert data['access_token']


def test_login_rejects_invalid_credentials(client):
    response = client.post(
        '/api/v1/auth/login',
        json={'email': 'admin@test.edu', 'password': 'WrongPassword123!'},
    )

    assert response.status_code == 401


def test_rbac_blocks_student_from_admin_student_lookup(client):
    login = client.post(
        '/api/v1/auth/login',
        json={'email': 'student@test.edu', 'password': 'StudentPass123!'},
    )
    token = login.json()['access_token']

    response = client.get(
        '/api/v1/student/admin/1',
        headers={'Authorization': f'Bearer {token}'},
    )

    assert response.status_code == 403
