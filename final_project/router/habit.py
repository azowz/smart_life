from fastapi import APIRouter, Depends, HTTPException, Path, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional

from final_project.db import get_session
from final_project.models.user import UserDB  # Import UserDB directly instead of User
from final_project.models.habit import HabitDB
from final_project.schemas.habit import HabitCreate, HabitResponse, HabitUpdate
from final_project.security import get_current_user  # Remove User from this import

router = APIRouter(prefix="/habits", tags=["habits"])

# Get all habits for current user
@router.get("/", response_model=List[HabitResponse])
async def list_habits(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, le=1000),
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    habits = session.query(HabitDB).filter(
        HabitDB.user_id == current_user.user_id
    ).offset(skip).limit(limit).all()
    return habits

# Create a new habit
@router.post("/", response_model=HabitResponse, status_code=status.HTTP_201_CREATED)
async def create_habit(
    habit: HabitCreate,
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    db_habit = HabitDB(
        name=habit.name,
        description=habit.description,
        frequency=habit.frequency,
        user_id=current_user.user_id,
        is_active=habit.is_active,
        # Add any other fields from your HabitCreate schema
    )
    session.add(db_habit)
    session.commit()
    session.refresh(db_habit)
    return db_habit

# Get habit by ID
@router.get("/{habit_id}", response_model=HabitResponse)
async def read_habit(
    habit_id: int = Path(..., gt=0),
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    habit = session.query(HabitDB).filter(
        HabitDB.habit_id == habit_id,
        HabitDB.user_id == current_user.user_id
    ).first()
    
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    
    return habit

# Update habit
@router.put("/{habit_id}", response_model=HabitResponse)
async def update_habit(
    habit_id: int = Path(..., gt=0),
    habit_update: HabitUpdate = ...,
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    db_habit = session.query(HabitDB).filter(
        HabitDB.habit_id == habit_id,
        HabitDB.user_id == current_user.user_id
    ).first()
    
    if not db_habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    
    # Update habit fields
    update_data = habit_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_habit, key, value)
    
    session.commit()
    session.refresh(db_habit)
    return db_habit

# Delete habit
@router.delete("/{habit_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_habit(
    habit_id: int = Path(..., gt=0),
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    db_habit = session.query(HabitDB).filter(
        HabitDB.habit_id == habit_id,
        HabitDB.user_id == current_user.user_id
    ).first()
    
    if not db_habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    
    session.delete(db_habit)
    session.commit()
    return None

# Toggle habit active status
@router.patch("/{habit_id}/toggle", response_model=HabitResponse)
async def toggle_habit_status(
    habit_id: int = Path(..., gt=0),
    current_user: UserDB = Depends(get_current_user),  # Changed User to UserDB
    session: Session = Depends(get_session)
):
    db_habit = session.query(HabitDB).filter(
        HabitDB.habit_id == habit_id,
        HabitDB.user_id == current_user.user_id
    ).first()
    
    if not db_habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    
    # Toggle active status
    db_habit.is_active = not db_habit.is_active
    
    session.commit()
    session.refresh(db_habit)
    return db_habit