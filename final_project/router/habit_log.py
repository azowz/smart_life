from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy.sql import func
from typing import List, Optional
from datetime import date

from final_project.db import get_session
from final_project.models.habit_log import HabitLogDB
from final_project.models.habit import HabitDB
from final_project.models.user import UserDB
from final_project.schemas.habit_log import HabitLogCreate, HabitLogUpdate, HabitLogResponse
from final_project.security import get_current_active_user

router = APIRouter(prefix="/habit-logs", tags=["habit-logs"])

# Helper function to verify habit ownership or superuser access
def verify_habit_access(session: Session, habit_id: int, current_user: UserDB):
    habit = session.query(HabitDB).filter(HabitDB.habit_id == habit_id).first()
    if not habit:
        raise HTTPException(status_code=404, detail="Habit not found")
    if habit.user_id != current_user.user_id and not current_user.superuser:
        raise HTTPException(status_code=403, detail="Not authorized")
    return habit

# Endpoint to create a new habit log entry
@router.post("/", response_model=HabitLogResponse)
async def create_habit_log(
    log: HabitLogCreate,
    current_user: UserDB = Depends(get_current_active_user),
    session: Session = Depends(get_session)
):
    habit = verify_habit_access(session, log.habit_id, current_user)

    # Check if a log already exists for this date
    if log.completed_date:
        existing_log = session.query(HabitLogDB).filter(
            HabitLogDB.habit_id == log.habit_id,
            HabitLogDB.completed_date == log.completed_date
        ).first()
        if existing_log:
            raise HTTPException(status_code=409, detail="A log entry for this date already exists")

    db_log = HabitLogDB(
        habit_id=log.habit_id,
        user_id=current_user.user_id,  # Add user ID to the log
        completed_date=log.completed_date or func.current_date(),
        notes=log.notes,
        value=log.value
    )
    session.add(db_log)
    session.commit()
    session.refresh(db_log)
    return db_log

# Endpoint to get logs for a specific habit
@router.get("/habit/{habit_id}", response_model=List[HabitLogResponse])
async def get_habit_logs(
    habit_id: int,
    start_date: Optional[date] = Query(None, description="Start date for filtering logs"),
    end_date: Optional[date] = Query(None, description="End date for filtering logs"),
    current_user: UserDB = Depends(get_current_active_user),
    session: Session = Depends(get_session)
):
    verify_habit_access(session, habit_id, current_user)

    query = session.query(HabitLogDB).filter(HabitLogDB.habit_id == habit_id)
    if start_date:
        query = query.filter(HabitLogDB.completed_date >= start_date)
    if end_date:
        query = query.filter(HabitLogDB.completed_date <= end_date)

    return query.order_by(HabitLogDB.completed_date.desc()).all()

# Endpoint to get a specific habit log by ID
@router.get("/{log_id}", response_model=HabitLogResponse)
async def get_habit_log(
    log_id: int,
    current_user: UserDB = Depends(get_current_active_user),
    session: Session = Depends(get_session)
):
    log = session.query(HabitLogDB).filter(HabitLogDB.log_id == log_id).first()
    if not log:
        raise HTTPException(status_code=404, detail="Log not found")

    verify_habit_access(session, log.habit_id, current_user)
    return log

# Endpoint to update a habit log
@router.patch("/{log_id}", response_model=HabitLogResponse)
async def update_habit_log(
    log_id: int,
    log_update: HabitLogUpdate,
    current_user: UserDB = Depends(get_current_active_user),
    session: Session = Depends(get_session)
):
    db_log = session.query(HabitLogDB).filter(HabitLogDB.log_id == log_id).first()
    if not db_log:
        raise HTTPException(status_code=404, detail="Log not found")

    verify_habit_access(session, db_log.habit_id, current_user)

    update_data = log_update.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_log, key, value)

    session.commit()
    session.refresh(db_log)
    return db_log

# Endpoint to delete a habit log
@router.delete("/{log_id}")
async def delete_habit_log(
    log_id: int,
    current_user: UserDB = Depends(get_current_active_user),
    session: Session = Depends(get_session)
):
    db_log = session.query(HabitLogDB).filter(HabitLogDB.log_id == log_id).first()
    if not db_log:
        raise HTTPException(status_code=404, detail="Log not found")

    verify_habit_access(session, db_log.habit_id, current_user)

    session.delete(db_log)
    session.commit()
    return {"message": "Log deleted successfully"}

# Endpoint to calculate streak for a specific habit
@router.get("/habit/{habit_id}/streak")
async def get_streak(
    habit_id: int,
    current_user: UserDB = Depends(get_current_active_user),
    session: Session = Depends(get_session)
):
    habit = verify_habit_access(session, habit_id, current_user)

    logs = session.query(HabitLogDB).filter(
        HabitLogDB.habit_id == habit_id
    ).order_by(HabitLogDB.completed_date.desc()).all()

    if not logs:
        return {"streak": 0}

    streak = 1
    # Calculate streak based on habit frequency
    if habit.frequency == 'daily':
        for i in range(len(logs) - 1):
            if (logs[i].completed_date - logs[i + 1].completed_date).days == 1:
                streak += 1
            else:
                break
    elif habit.frequency == 'weekly':
        for i in range(len(logs) - 1):
            if 1 <= (logs[i].completed_date - logs[i + 1].completed_date).days <= 14:
                streak += 1
            else:
                break
    elif habit.frequency == 'monthly':
        for i in range(len(logs) - 1):
            curr = logs[i].completed_date
            next_ = logs[i + 1].completed_date
            if (curr.month - 1 == next_.month and curr.year == next_.year) or (curr.month == 1 and next_.month == 12 and curr.year == next_.year + 1):
                streak += 1
            else:
                break

    return {"streak": streak}