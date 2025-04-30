from typing import Optional, List
from enum import Enum
from sqlalchemy import func

from final_project.models.default_habit import DefaultHabitDB
from final_project.models.user_default_habit import UserDefaultHabitDB
from final_project.schemas.default_habit import DefaultHabitCreate, DefaultHabitUpdate

def create_default_habit(db_session, habit_data: DefaultHabitCreate):
    """
    Create a new default habit

    Args:
        db_session: SQLAlchemy database session
        habit_data: Default habit data

    Returns:
        The created default habit
    """
    # Convert Pydantic model to dict and handle Enum values
    habit_dict = habit_data.dict()
    if isinstance(habit_dict.get('frequency'), Enum):
        habit_dict['frequency'] = habit_dict['frequency'].value

    db_habit = DefaultHabitDB(**habit_dict)
    db_session.add(db_habit)
    db_session.commit()
    db_session.refresh(db_habit)
    return db_habit

def update_default_habit(db_session, default_habit_id: int, habit_data: DefaultHabitUpdate):
    """
    Update an existing default habit

    Args:
        db_session: SQLAlchemy database session
        default_habit_id: ID of the default habit to update
        habit_data: Default habit update data

    Returns:
        The updated default habit or None if not found
    """
    db_habit = db_session.query(DefaultHabitDB).filter(
        DefaultHabitDB.default_habit_id == default_habit_id
    ).first()

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

def get_default_habit(db_session, default_habit_id: int):
    """
    Get a specific default habit by ID

    Args:
        db_session: SQLAlchemy database session
        default_habit_id: ID of the default habit

    Returns:
        The default habit or None if not found
    """
    return db_session.query(DefaultHabitDB).filter(
        DefaultHabitDB.default_habit_id == default_habit_id
    ).first()

def get_default_habits(db_session, active_only: bool = True, category_id: Optional[int] = None,
                       ai_recommended: Optional[bool] = None) -> List[DefaultHabitDB]:
    """
    Get default habits with optional filtering

    Args:
        db_session: SQLAlchemy database session
        active_only: If True, return only active default habits
        category_id: Optional category ID to filter by
        ai_recommended: Optional filter for AI recommended habits

    Returns:
        List of default habits
    """
    query = db_session.query(DefaultHabitDB)

    if active_only:
        query = query.filter(DefaultHabitDB.is_active == True)

    if category_id is not None:
        query = query.filter(DefaultHabitDB.category_id == category_id)

    if ai_recommended is not None:
        query = query.filter(DefaultHabitDB.ai_recommended == ai_recommended)

    return query.order_by(
        DefaultHabitDB.effectiveness_score.desc(),
        DefaultHabitDB.name
    ).all()

def update_adoption_rate(db_session, default_habit_id: int):
    """
    Calculate and update the adoption rate for a default habit

    Args:
        db_session: SQLAlchemy database session
        default_habit_id: ID of the default habit

    Returns:
        The updated adoption rate or None if default habit not found
    """
    # Get the default habit
    db_habit = db_session.query(DefaultHabitDB).filter(
        DefaultHabitDB.default_habit_id == default_habit_id
    ).first()

    if not db_habit:
        return None

    # Count how many users have adopted this habit
    adopted_count = db_session.query(func.count(UserDefaultHabitDB.user_id)).filter(
        UserDefaultHabitDB.default_habit_id == default_habit_id,
        UserDefaultHabitDB.is_active == True
    ).scalar() or 0

    # Count how many users have been shown this habit (suggested to them)
    shown_count = db_session.query(func.count(UserDefaultHabitDB.user_id)).filter(
        UserDefaultHabitDB.default_habit_id == default_habit_id
    ).scalar() or 0

    # Calculate adoption rate
    if shown_count > 0:
        adoption_rate = (adopted_count / shown_count) * 100
    else:
        adoption_rate = 0

    # Update the default habit
    db_habit.adoption_rate = round(adoption_rate, 2)
    db_session.commit()

    return db_habit.adoption_rate

def delete_default_habit(db_session, default_habit_id: int):
    """
    Delete a default habit

    Args:
        db_session: SQLAlchemy database session
        default_habit_id: ID of the default habit to delete

    Returns:
        True if deleted, False if not found
    """
    db_habit = db_session.query(DefaultHabitDB).filter(
        DefaultHabitDB.default_habit_id == default_habit_id
    ).first()

    if not db_habit:
        return False

    db_session.delete(db_habit)
    db_session.commit()
    return True