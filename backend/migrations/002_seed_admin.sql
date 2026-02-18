-- Replace the password hash before production use.
INSERT INTO users (email, full_name, hashed_password, role)
VALUES
    (
        'admin@university.edu',
        'University Admin',
        '$2b$12$5SG5Tiu27htLQ6LQn.rXeOV6G7lY2vUYVx1f9h6XT4I6Um0z7Pcca',
        'admin'
    )
ON CONFLICT (email) DO NOTHING;
