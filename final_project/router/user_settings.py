from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from final_project.db import get_session
from final_project.models.user_settings import UserSettingsDB
from final_project.models.user import UserDB
from final_project.schemas.user_settings import UserSettingsCreate, UserSettingsResponse
from final_project.security import get_current_user

router = APIRouter(prefix="/user-settings", tags=["user-settings"])

# Helper function to get user settings from the database
def get_user_settings(db_session: Session, user_id: int):
    return db_session.query(UserSettingsDB).filter(UserSettingsDB.user_id == user_id).first()

# Helper function to create default settings for a user
def create_default_settings(db_session: Session, user_id: int):
    default_settings = UserSettingsDB(
        user_id=user_id,
        theme="system",
        notification_preferences={},
        language="en",
        time_zone="UTC",
        ai_assistant_enabled=True
    )
    db_session.add(default_settings)
    db_session.commit()
    db_session.refresh(default_settings)
    return default_settings

# Endpoint to create user settings (accessible by the user or superuser)
@router.post("/", response_model=UserSettingsResponse)
async def create_settings(
    settings: UserSettingsCreate,
    session: Session = Depends(get_session),
    current_user: UserDB = Depends(get_current_user)
):
    if current_user.user_id != settings.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="You don't have permission to modify this user's settings")

    existing = get_user_settings(session, settings.user_id)
    if existing:
        raise HTTPException(status_code=409, detail="Settings already exist for this user")

    db_settings = UserSettingsDB(**settings.dict())
    session.add(db_settings)
    session.commit()
    session.refresh(db_settings)
    return db_settings

# Endpoint to get user settings (accessible by the user or superuser)
@router.get("/{user_id}", response_model=UserSettingsResponse)
async def get_settings(
    user_id: int,
    session: Session = Depends(get_session),
    current_user: UserDB = Depends(get_current_user)
):
    if current_user.user_id != user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="You don't have permission to access this user's settings")

    settings = get_user_settings(session, user_id)
    if not settings:
        settings = create_default_settings(session, user_id)
    return settings

# Endpoint to update user settings (accessible by the user or superuser)
@router.patch("/{user_id}", response_model=UserSettingsResponse)
async def update_settings(
    user_id: int,
    patch: UserSettingsCreate,
    session: Session = Depends(get_session),
    current_user: UserDB = Depends(get_current_user)
):
    if current_user.user_id != user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="You don't have permission to modify this user's settings")

    settings = get_user_settings(session, user_id)
    if not settings:
        raise HTTPException(status_code=404, detail="Settings not found")

    for key, value in patch.dict(exclude_unset=True).items():
        setattr(settings, key, value)

    session.commit()
    session.refresh(settings)
    return settings

# Endpoint to delete user settings (accessible by the user or superuser)
@router.delete("/{user_id}")
async def delete_settings(
    user_id: int,
    session: Session = Depends(get_session),
    current_user: UserDB = Depends(get_current_user)
):
    if current_user.user_id != user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="You don't have permission to delete this user's settings")

    settings = get_user_settings(session, user_id)
    if not settings:
        raise HTTPException(status_code=404, detail="Settings not found")

    session.delete(settings)
    session.commit()
    return {"message": "Settings deleted successfully"}