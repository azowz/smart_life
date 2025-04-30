from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta

from ..config import settings
from ..schemas.token import Token, RefreshToken
from ..security import (
    authenticate_user,  # Function to authenticate user credentials
    create_access_token,  # Function to create access token
    create_refresh_token,  # Function to create refresh token
    validate_token  # Function to validate refresh token
)
from final_project.db import get_db

# Token expiration settings
ACCESS_TOKEN_EXPIRE_MINUTES = settings.security.access_token_expire_minutes
REFRESH_TOKEN_EXPIRE_MINUTES = settings.security.refresh_token_expires_in_minutes

router = APIRouter(prefix="/auth", tags=["authentication"])

# Login endpoint to issue access and refresh tokens
@router.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    session: Session = Depends(get_db),
):
    # Authenticate user credentials
    user = authenticate_user(session, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Generate access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "fresh": True},
        expires_delta=access_token_expires,
    )

    # Generate refresh token
    refresh_token_expires = timedelta(minutes=REFRESH_TOKEN_EXPIRE_MINUTES)
    refresh_token = create_refresh_token(
        data={"sub": user.username}, expires_delta=refresh_token_expires
    )

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }

# Endpoint to refresh access and refresh tokens
@router.post("/refresh_token", response_model=Token)
async def refresh_token(form_data: RefreshToken):
    # Validate the refresh token and retrieve the user
    user = validate_token(token=form_data.refresh_token)

    # Generate new access token
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username, "fresh": False},
        expires_delta=access_token_expires,
    )

    # Generate new refresh token
    refresh_token_expires = timedelta(minutes=REFRESH_TOKEN_EXPIRE_MINUTES)
    refresh_token = create_refresh_token(
        data={"sub": user.username}, expires_delta=refresh_token_expires
    )

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }