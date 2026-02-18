from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import auth, student

app = FastAPI(title='University Student API', version='0.1.0')

app.add_middleware(
    CORSMiddleware,
    allow_origins=['http://localhost:3000', 'http://localhost:8080'],
    allow_credentials=True,
    allow_methods=['GET', 'POST'],
    allow_headers=['Authorization', 'Content-Type'],
)


@app.get('/health')
def health_check():
    return {'status': 'ok'}


app.include_router(auth.router, prefix='/api/v1')
app.include_router(student.router, prefix='/api/v1')
