from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from ..config import settings
from ..db import get_session
from ..models.user import UserDB
from ..schemas.token import Token, RefreshToken
from ..security import (
    verify_password,       # Function to verify password hash
    create_access_token,   # Function to create access token
    create_refresh_token,  # Function to create refresh token
    validate_token         # Function to validate refresh token
)

# Token expiration settings
ACCESS_TOKEN_EXPIRE_MINUTES = settings.security.access_token_expire_minutes
REFRESH_TOKEN_EXPIRE_MINUTES = settings.security.refresh_token_expire_minutes

router = APIRouter()

# 🔒 Retrieve user from database by username
def get_user(session: Session, username: str) -> UserDB:
    return session.query(UserDB).filter(UserDB.username == username).first()

# ✅ Authenticate user credentials (username & password)
def authenticate_user(session: Session, username: str, password: str) -> UserDB:
    user = get_user(session, username)
    if not user or not verify_password(password, user.password_hash):
        return None
    return user

# ✅ Generate access and refresh tokens upon login
@router.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    session: Session = Depends(get_session),
):
    user = authenticate_user(session, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Generate access and refresh tokens
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "fresh": True},
        expires_delta=access_token_expires,
    )

    refresh_token_expires = timedelta(minutes=REFRESH_TOKEN_EXPIRE_MINUTES)
    refresh_token = create_refresh_token(
        data={"sub": user.username}, expires_delta=refresh_token_expires
    )

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }

# 🔁 Generate new tokens using refresh token
@router.post("/refresh_token", response_model=Token)
async def refresh_token(form_data: RefreshToken):
    # Validate refresh token and get user info
    user = validate_token(token=form_data.refresh_token)  # Removed 'await' here

    # Generate new access and refresh tokens
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "fresh": False},
        expires_delta=access_token_expires,
    )

    refresh_token_expires = timedelta(minutes=REFRESH_TOKEN_EXPIRE_MINUTES)
    refresh_token = create_refresh_token(
        data={"sub": user.username}, expires_delta=refresh_token_expires
    )

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }
