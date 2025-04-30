from typing import List, Dict, Any, Optional
from datetime import date
from enum import Enum
from sqlalchemy import func

from final_project.models.habit import HabitDB
from final_project.models.habit_log import HabitLogDB
from final_project.schemas.habit import HabitCreate, HabitUpdate, HabitLogCreate, HabitLogUpdate

def create_habit(db_session, habit_data: HabitCreate):
    """
    Create a new habit
    
    Args:
        db_session: SQLAlchemy database session
        habit_data: Habit data
        
    Returns:
        The created habit
    """
    # Convert Pydantic model to dict and handle Enum values
    habit_dict = habit_data.dict()
    if isinstance(habit_dict.get('frequency'), Enum):
        habit_dict['frequency'] = habit_dict['frequency'].value
    
    db_habit = HabitDB(**habit_dict)
    db_session.add(db_habit)
    db_session.commit()
    db_session.refresh(db_habit)
    return db_habit

def update_habit(db_session, habit_id: int, habit_data: HabitUpdate):
    """
    Update an existing habit
    
    Args:
        db_session: SQLAlchemy database session
        habit_id: ID of the habit to update
        habit_data: Habit update data
        
    Returns:
        The updated habit or None if not found
    """
    db_habit = db_session.query(HabitDB).filter(HabitDB.habit_id == habit_id).first()
    if not db_habit:
        return None
    
    # Update only the fields that are provided
    update_data = habit_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        if isinstance(value, Enum):
            setattr(db_habit, key, value.value)
        else:
            setattr(db_habit, key, value)
    
    db_session.commit()
    db_session.refresh(db_habit)
    return db_habit

def get_habit(db_session, habit_id: int):
    """
    Get a habit by ID
    
    Args:
        db_session: SQLAlchemy database session
        habit_id: ID of the habit to retrieve
        
    Returns:
        The habit or None if not found
    """
    return db_session.query(HabitDB).filter(HabitDB.habit_id == habit_id).first()

def get_habits(db_session, user_id: Optional[int] = None, is_default: Optional[bool] = None):
    """
    Get habits with optional filtering
    
    Args:
        db_session: SQLAlchemy database session
        user_id: Optional user ID to filter by
        is_default: Optional filter for default habits
        
    Returns:
        List of habits
    """
    query = db_session.query(HabitDB)
    
    if user_id is not None:
        query = query.filter(HabitDB.user_id == user_id)
    
    if is_default is not None:
        query = query.filter(HabitDB.is_default_habit == is_default)
    
    return query.order_by(HabitDB.name).all()

def get_user_habits(db_session, user_id: int) -> List[HabitDB]:
    """
    Get all habits for a specific user
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        
    Returns:
        List of habits
    """
    return db_session.query(HabitDB).filter(
        HabitDB.user_id == user_id
    ).order_by(HabitDB.name).all()

def add_reminder_to_habit(db_session, habit_id: int, reminder: Dict[str, Any]):
    """
    Add a reminder to a habit
    
    Args:
        db_session: SQLAlchemy database session
        habit_id: ID of the habit
        reminder: Reminder data (dict with time, days, etc.)
        
    Returns:
        The updated habit or None if not found
    """
    db_habit = db_session.query(HabitDB).filter(HabitDB.habit_id == habit_id).first()
    if not db_habit:
        return None
    
    # Initialize reminders if None
    current_reminders = db_habit.reminders or []
    current_reminders.append(reminder)
    db_habit.reminders = current_reminders
    
    db_session.commit()
    db_session.refresh(db_habit)
    return db_habit

def remove_reminder_from_habit(db_session, habit_id: int, reminder_index: int):
    """
    Remove a reminder from a habit
    
    Args:
        db_session: SQLAlchemy database session
        habit_id: ID of the habit
        reminder_index: Index of the reminder to remove
        
    Returns:
        The updated habit or None if not found or index out of range
    """
    db_habit = db_session.query(HabitDB).filter(HabitDB.habit_id == habit_id).first()
    if not db_habit:
        return None
    
    current_reminders = db_habit.reminders or []
    if 0 <= reminder_index < len(current_reminders):
        current_reminders.pop(reminder_index)
        db_habit.reminders = current_reminders
        
        db_session.commit()
        db_session.refresh(db_habit)
        return db_habit
    
    return None

def create_habit_from_default(db_session, user_id: int, default_habit_id: int):
    """
    Create a user habit from a default habit template
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        default_habit_id: ID of the default habit to copy
        
    Returns:
        The created habit or None if default habit not found
    """
    default_habit = db_session.query(HabitDB).filter(
        HabitDB.habit_id == default_habit_id,
        HabitDB.is_default_habit == True
    ).first()
    
    if not default_habit:
        return None
    
    # Create a new habit based on the default one
    new_habit = HabitDB(
        user_id=user_id,
        name=default_habit.name,
        color=default_habit.color,
        color_name=default_habit.color_name,
        description=default_habit.description,
        frequency=default_habit.frequency,
        reminders=default_habit.reminders,
        time=default_habit.time,
        start_date=func.current_date(),
        target_count=default_habit.target_count,
        is_default_habit=False,
        default_habit_id=default_habit.habit_id,
        ai_generated=default_habit.ai_generated
    )
    
    db_session.add(new_habit)
    db_session.commit()
    db_session.refresh(new_habit)
    return new_habit

def delete_habit(db_session, habit_id: int):
    """
    Delete a habit
    
    Args:
        db_session: SQLAlchemy database session
        habit_id: ID of the habit to delete
        
    Returns:
        True if deleted, False if not found
    """
    habit = db_session.query(HabitDB).filter(HabitDB.habit_id == habit_id).first()
    if not habit:
        return False
    
    db_session.delete(habit)
    db_session.commit()
    return True

# Habit Log functions
def create_habit_log(db_session, log_data: HabitLogCreate):
    """
    Create a new habit log entry
    
    Args:
        db_session: SQLAlchemy database session
        log_data: Habit log data
        
    Returns:
        The created log entry
    """
    db_log = HabitLogDB(**log_data.dict())
    db_session.add(db_log)
    db_session.commit()
    db_session.refresh(db_log)
    return db_log

def get_habit_log(db_session, log_id: int):
    """
    Get a habit log by ID
    
    Args:
        db_session: SQLAlchemy database session
        log_id: ID of the log to retrieve
        
    Returns:
        The log entry or None if not found
    """
    return db_session.query(HabitLogDB).filter(HabitLogDB.log_id == log_id).first()

def get_habit_logs(db_session, habit_id: int, start_date: Optional[date] = None, 
                  end_date: Optional[date] = None) -> List[HabitLogDB]:
    """
    Get logs for a specific habit with optional date filtering
    
    Args:
        db_session: SQLAlchemy database session
        habit_id: The habit ID
        start_date: Optional start date for filtering
        end_date: Optional end date for filtering
        
    Returns:
        List of habit logs
    """
    query = db_session.query(HabitLogDB).filter(HabitLogDB.habit_id == habit_id)
    
    if start_date:
        query = query.filter(HabitLogDB.completed_date >= start_date)
    
    if end_date:
        query = query.filter(HabitLogDB.completed_date <= end_date)
    
    return query.order_by(HabitLogDB.completed_date.desc()).all()

def update_habit_log(db_session, log_id: int, log_data: HabitLogUpdate):
    """
    Update a habit log entry
    
    Args:
        db_session: SQLAlchemy database session
        log_id: ID of the log to update
        log_data: Updated log data
        
    Returns:
        The updated log entry or None if not found
    """
    db_log = db_session.query(HabitLogDB).filter(HabitLogDB.log_id == log_id).first()
    if not db_log:
        return None
    
    # Update only the fields that are provided
    update_data = log_data.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_log, key, value)
    
    db_session.commit()
    db_session.refresh(db_log)
    return db_log

def delete_habit_log(db_session, log_id: int):
    """
    Delete a habit log entry
    
    Args:
        db_session: SQLAlchemy database session
        log_id: ID of the log to delete
        
    Returns:
        True if deleted, False if not found
    """
    db_log = db_session.query(HabitLogDB).filter(HabitLogDB.log_id == log_id).first()
    if not db_log:
        return False
    
    db_session.delete(db_log)
    db_session.commit()
    return True

def get_habit_logs_by_date(db_session, habit_id: int, completed_date: date):
    """
    Get logs for a specific habit on a specific date
    
    Args:
        db_session: SQLAlchemy database session
        habit_id: The habit ID
        completed_date: The date to filter by
        
    Returns:
        List of habit logs
    """
    return db_session.query(HabitLogDB).filter(
        HabitLogDB.habit_id == habit_id,
        HabitLogDB.completed_date == completed_date
    ).all()

def get_user_habit_logs(db_session, user_id: int, start_date: Optional[date] = None, 
                        end_date: Optional[date] = None) -> List[HabitLogDB]:
    """
    Get all habit logs for a specific user
    
    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        start_date: Optional start date for filtering
        end_date: Optional end date for filtering
        
    Returns:
        List of habit logs
    """
    query = db_session.query(HabitLogDB).join(
        HabitDB, HabitDB.habit_id == HabitLogDB.habit_id
    ).filter(
        HabitDB.user_id == user_id
    )
    
    if start_date:
        query = query.filter(HabitLogDB.completed_date >= start_date)
    
    if end_date:
        query = query.filter(HabitLogDB.completed_date <= end_date)
    
    return query.order_by(HabitLogDB.completed_date.desc()).all()