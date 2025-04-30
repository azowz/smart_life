from datetime import datetime, timedelta
from typing import Optional, Union

from fastapi import Depends, HTTPException, Request, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session

from final_project.config import settings
from final_project.db import get_session
from final_project.models.user import UserDB

# Password and token settings
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

SECRET_KEY = settings.security.secret_key
ALGORITHM = settings.security.algorithm

# Token verification functions
def verify_password(plain_password, hashed_password) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password) -> str:
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire, "scope": "access_token"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def create_refresh_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire, "scope": "refresh_token"})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# User authentication functions
def get_user(session: Session, username: str) -> Optional[UserDB]:
    return session.query(UserDB).filter(UserDB.username == username).first()

def authenticate_user(session: Session, username: str, password: str) -> Union[UserDB, bool]:
    user = get_user(session, username)
    if not user:
        return False
    if not verify_password(password, user.password_hash):
        return False
    return user

# Current user dependency functions
def get_current_user(
    token: str = Depends(oauth2_scheme), 
    request: Request = None, 
    session: Session = Depends(get_session),
    fresh: bool = False
) -> UserDB:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )

    if request:
        if authorization := request.headers.get("authorization"):
            try:
                token = authorization.split(" ")[1]
            except IndexError:
                raise credentials_exception

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")

        if username is None:
            raise credentials_exception
            
        # Check token scope
        if payload.get("scope") != "access_token":
            raise credentials_exception
            
        # Check if token is fresh when required
        if fresh and not payload.get("fresh", False):
            user = get_user(session, username)
            if not user or not user.superuser:
                raise credentials_exception
    except JWTError:
        raise credentials_exception
        
    user = get_user(session, username)
    if user is None:
        raise credentials_exception

    return user

async def get_current_active_user(
    current_user: UserDB = Depends(get_current_user),
) -> UserDB:
    if not current_user.is_active:
        raise HTTPException(status_code=400, detail="Inactive user")
    return current_user

def get_current_fresh_user(
    token: str = Depends(oauth2_scheme), 
    request: Request = None,
    session: Session = Depends(get_session)
) -> UserDB:
    return get_current_user(token, request, session, True)

async def get_current_admin_user(
    current_user: UserDB = Depends(get_current_user),
) -> UserDB:
    if not current_user.superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Not an admin user"
        )
    return current_user

async def validate_token(
    token: str = Depends(oauth2_scheme),
    session: Session = Depends(get_session)
) -> UserDB:
    user = get_current_user(token=token, session=session)
    return user

# Easy to use dependencies
AuthenticatedUser = Depends(get_current_active_user)
FreshUser = Depends(get_current_fresh_user)
AdminUser = Depends(get_current_admin_user)