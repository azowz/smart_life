import io
import os

from fastapi import FastAPI
from starlette.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from .config import settings
from .db import create_db_and_tables, engine
from .models.admin.admin import AdminDB
from .models.user import UserDB
from .models.user_settings import UserSettingsDB
from .security import get_password_hash
from .router import main_router


# ✅ read copy from fiel 
def read(*paths, **kwargs):
    with io.open(                                                          # io.open() is used to open a file in a way that is compatible with both text and binary files.
        os.path.join(os.path.dirname(file), *paths),
        encoding=kwargs.get("encoding", "utf8"),
    ) as open_file:
        return open_file.read().strip()                                    # read() read file in one sequence and strip()  remove spaces from api 


# ✅ create FastAPI
app = FastAPI(
    title="Smart Life Organizer",
    description="Smart Life Organizer API helps you organize your tasks and habits with AI. 🚀",
    version=read("VERSION"),
    terms_of_service="http://final_project.com/terms/",
    contact={
        "name": "Su03l",
        "url": "http://final_project.com/contact/",
        "email": "admin@example.com",
    },
    license_info={
        "name": "The Unlicense",
        "url": "https://unlicense.org",
    },
)

# ✅   add settings CORS layer 
if settings.server and settings.server.get("cors_origins", None):
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.server["cors_origins"],                                            # pandwith the origins of the requests that are allowed to access the API.
        allow_credentials=settings.server.get("cors_allow_credentials", True),                    # allow credentials to be included in the requests (e.g., cookies, authorization headers).
        allow_origin_regex=settings.server.get("cors_allow_origin_regex", None),                  # allow regex patterns for origins
        allow_methods=settings.server.get("cors_allow_methods", ["*"]),                           # allow all HTTP methods (GET, POST, PUT, DELETE, etc.) to be used in the requests.
        allow_headers=settings.server.get("cors_allow_headers", ["*"]),
    )

# ✅  logging router point 
app.include_router(main_router)

 
@app.get("/")
def root():
    return {"message": "Welcome to the Smart Life Organizer API"}                                 # welcome message