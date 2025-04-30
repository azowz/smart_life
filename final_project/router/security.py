from datetime import timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from sqlalchemy.sql import func

from final_project.config import settings
from final_project.db import get_session
from final_project.models.user import UserDB
from final_project.schemas.token import Token, RefreshToken
from final_project.security import (
    authenticate_user,
    create_access_token,
    create_refresh_token,
    validate_token,
)

ACCESS_TOKEN_EXPIRE_MINUTES = settings.security.access_token_expire_minutes
REFRESH_TOKEN_EXPIRE_MINUTES = settings.security.refresh_token_expire_minutes  # Make sure this matches your settings

router = APIRouter(tags=["authentication"])

# Login endpoint to issue access & refresh tokens
@router.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    session: Session = Depends(get_session),
):
    # Authenticate user
    user = authenticate_user(session, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Update last_login timestamp
    user.last_login = func.now()
    session.commit()

    # Generate tokens
    access_token = create_access_token(
        data={"sub": user.username, "fresh": True},
        expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
    )
    refresh_token = create_refresh_token(
        data={"sub": user.username},
        expires_delta=timedelta(minutes=REFRESH_TOKEN_EXPIRE_MINUTES),
    )

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }

# Refresh token endpoint
@router.post("/refresh_token", response_model=Token)
async def refresh_token_endpoint(
    form_data: RefreshToken,
    session: Session = Depends(get_session),
):
    try:
        # Validate refresh token and retrieve user
        user = validate_token(token=form_data.refresh_token, session=session)

        # Generate new tokens
        access_token = create_access_token(
            data={"sub": user.username, "fresh": False},
            expires_delta=timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
        )
        refresh_token = create_refresh_token(
            data={"sub": user.username},
            expires_delta=timedelta(minutes=REFRESH_TOKEN_EXPIRE_MINUTES),
        )

        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
        }
    except HTTPException:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
            headers={"WWW-Authenticate": "Bearer"},
        )