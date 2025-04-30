from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from final_project.db import get_session
from final_project.models.user import UserDB
from final_project.schemas.user import UserCreate, UserResponse, UserUpdate
from final_project.security import (
    get_password_hash, 
    get_current_active_user, 
    get_current_admin_user
)

router = APIRouter(prefix="/users", tags=["users"])

# Helper function to query users - made available for other modules
def query_user(session: Session, user_id: int) -> Optional[UserDB]:
    """Get user by ID - helper function that can be imported by other modules"""
    return session.query(UserDB).filter(UserDB.user_id == user_id).first()

# Get current user profile
@router.get("/me", response_model=UserResponse)
async def read_users_me(
    current_user: UserDB = Depends(get_current_active_user)
):
    return current_user

# Update current user profile
@router.patch("/me", response_model=UserResponse)
async def update_user_me(
    user_update: UserUpdate,
    current_user: UserDB = Depends(get_current_active_user),
    session: Session = Depends(get_session)
):
    # Update user fields
    update_data = user_update.dict(exclude_unset=True)
    
    # Handle password update separately if provided
    if "password" in update_data:
        update_data["password_hash"] = get_password_hash(update_data.pop("password"))
    
    for key, value in update_data.items():
        setattr(current_user, key, value)
    
    session.commit()
    session.refresh(current_user)
    return current_user

# 🔥 Public endpoint: User self-registration (NO authentication required)
@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register_user(
    user: UserCreate,
    session: Session = Depends(get_session)
):
    # Check if username already exists
    db_user = session.query(UserDB).filter(UserDB.username == user.username).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    
    # Check if email already exists
    db_user = session.query(UserDB).filter(UserDB.email == user.email).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = UserDB(
        username=user.username,
        email=user.email,
        password_hash=hashed_password,
        first_name=user.first_name,
        last_name=user.last_name,
        gender=user.gender,
        phone_number=user.phone_number,
        is_active=True,       # Active after registration
        superuser=False       # Regular user by default
    )
    
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user

# Admin endpoints below

# Get all users (admin only)
@router.get("/", response_model=List[UserResponse])
async def read_users(
    skip: int = 0, 
    limit: int = 100,
    current_user: UserDB = Depends(get_current_admin_user),
    session: Session = Depends(get_session)
):
    users = session.query(UserDB).offset(skip).limit(limit).all()
    return users

# Create new user (admin only)
@router.post("/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user: UserCreate,
    current_user: UserDB = Depends(get_current_admin_user),
    session: Session = Depends(get_session)
):
    # Check if username already exists
    db_user = session.query(UserDB).filter(UserDB.username == user.username).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already registered"
        )
    
    # Check if email already exists
    db_user = session.query(UserDB).filter(UserDB.email == user.email).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = UserDB(
        username=user.username,
        email=user.email,
        password_hash=hashed_password,
        first_name=user.first_name,
        last_name=user.last_name,
        gender=user.gender,
        phone_number=user.phone_number,
        is_active=user.is_active,
        superuser=user.superuser
    )
    
    session.add(db_user)
    session.commit()
    session.refresh(db_user)
    return db_user

# Get user by ID (admin only)
@router.get("/{user_id}", response_model=UserResponse)
async def read_user(
    user_id: int,
    current_user: UserDB = Depends(get_current_admin_user),
    session: Session = Depends(get_session)
):
    db_user = query_user(session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

# Update user by ID (admin only)
@router.patch("/{user_id}", response_model=UserResponse)
async def update_user(
    user_id: int,
    user_update: UserUpdate,
    current_user: UserDB = Depends(get_current_admin_user),
    session: Session = Depends(get_session)
):
    db_user = query_user(session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Update user fields
    update_data = user_update.dict(exclude_unset=True)
    
    if "password" in update_data:
        update_data["password_hash"] = get_password_hash(update_data.pop("password"))
    
    for key, value in update_data.items():
        setattr(db_user, key, value)
    
    session.commit()
    session.refresh(db_user)
    return db_user

# Delete user (admin only)
@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int,
    current_user: UserDB = Depends(get_current_admin_user),
    session: Session = Depends(get_session)
):
    db_user = query_user(session, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    if db_user.user_id == current_user.user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cannot delete your own account"
        )
    
    session.delete(db_user)
    session.commit()
    return None
