from fastapi import APIRouter, Depends, HTTPException, Path, Query
from sqlalchemy.orm import Session
from typing import List

from ..services.user_default_habit import (
    assign_default_habit,
    update_user_default_habit,
    get_user_default_habits,
    get_user_default_habit,
    get_default_habit_users,
    get_ai_recommended_habits,
    remove_default_habit
)
from ..router.user import query_user
from ..services.default_habit import get_default_habit
from ..schemas.user_default_habit import UserDefaultHabitCreate, UserDefaultHabitUpdate, UserDefaultHabitResponse
from ..db import get_db

router = APIRouter(prefix="/user-default-habits", tags=["User Default Habits"])

@router.post("/", response_model=UserDefaultHabitResponse)
def assign_habit_to_user(habit_data: UserDefaultHabitCreate, db: Session = Depends(get_db)):
    """Assign a default habit to a user"""
    user = query_user(db, habit_data.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    default_habit = get_default_habit(db, habit_data.default_habit_id)
    if not default_habit:
        raise HTTPException(status_code=404, detail="Default habit not found")
    return assign_default_habit(db, habit_data)

@router.get("/user/{user_id}", response_model=List[UserDefaultHabitResponse])
def get_habits_for_user(user_id: int = Path(...), active_only: bool = Query(False), db: Session = Depends(get_db)):
    """Get all default habits assigned to a user"""
    user = query_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return get_user_default_habits(db, user_id, active_only)

@router.get("/habit/{default_habit_id}", response_model=List[UserDefaultHabitResponse])
def get_users_for_habit(default_habit_id: int = Path(...), active_only: bool = Query(False), db: Session = Depends(get_db)):
    """Get all users who have been assigned a specific default habit"""
    default_habit = get_default_habit(db, default_habit_id)
    if not default_habit:
        raise HTTPException(status_code=404, detail="Default habit not found")
    return get_default_habit_users(db, default_habit_id, active_only)

@router.get("/user/{user_id}/habit/{default_habit_id}", response_model=UserDefaultHabitResponse)
def get_user_habit(user_id: int = Path(...), default_habit_id: int = Path(...), db: Session = Depends(get_db)):
    """Get a specific user-default habit assignment"""
    user = query_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    default_habit = get_default_habit(db, default_habit_id)
    if not default_habit:
        raise HTTPException(status_code=404, detail="Default habit not found")
    user_default_habit = get_user_default_habit(db, user_id, default_habit_id)
    if not user_default_habit:
        raise HTTPException(status_code=404, detail="User default habit assignment not found")
    return user_default_habit

@router.get("/user/{user_id}/ai-recommended", response_model=List[UserDefaultHabitResponse])
def get_ai_recommended_for_user(user_id: int = Path(...), active_only: bool = Query(False), db: Session = Depends(get_db)):
    """Get all AI-recommended habits for a user"""
    user = query_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return get_ai_recommended_habits(db, user_id, active_only)

@router.put("/user/{user_id}/habit/{default_habit_id}", response_model=UserDefaultHabitResponse)
def update_habit_assignment(habit_data: UserDefaultHabitUpdate, user_id: int = Path(...), default_habit_id: int = Path(...), db: Session = Depends(get_db)):
    """Update a user's default habit assignment"""
    user = query_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    default_habit = get_default_habit(db, default_habit_id)
    if not default_habit:
        raise HTTPException(status_code=404, detail="Default habit not found")
    updated_habit = update_user_default_habit(db, user_id, default_habit_id, habit_data)
    if not updated_habit:
        raise HTTPException(status_code=404, detail="User default habit assignment not found")
    return updated_habit

@router.delete("/user/{user_id}/habit/{default_habit_id}")
def delete_habit_assignment(user_id: int = Path(...), default_habit_id: int = Path(...), db: Session = Depends(get_db)):
    """Remove a default habit assignment for a user"""
    user = query_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    default_habit = get_default_habit(db, default_habit_id)
    if not default_habit:
        raise HTTPException(status_code=404, detail="Default habit not found")
    result = remove_default_habit(db, user_id, default_habit_id)
    if not result:
        raise HTTPException(status_code=404, detail="User default habit assignment not found")
    return {"message": "User default habit assignment removed successfully"}
