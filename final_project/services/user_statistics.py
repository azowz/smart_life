from typing import Optional, List
from datetime import date, datetime, timedelta
from sqlalchemy import func, case

from final_project.models.user_statistics import UserStatisticsDB
from final_project.models.task import TaskDB
from final_project.models.habit import HabitDB, HabitLogDB
from final_project.models.ai_interaction import AIInteractionDB
from final_project.schemas.user_statistics import UserStatisticsUpdate

def get_user_statistics(db_session, user_id: int, start_date: Optional[date] = None, end_date: Optional[date] = None) -> List[UserStatisticsDB]:
    """
    Get statistics for a user within a date range

    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID
        start_date: Optional start date for filtering
        end_date: Optional end date for filtering

    Returns:
        List of user statistics entries
    """
    query = db_session.query(UserStatisticsDB).filter(
        UserStatisticsDB.user_id == user_id
    )

    if start_date:
        query = query.filter(UserStatisticsDB.date >= start_date)

    if end_date:
        query = query.filter(UserStatisticsDB.date <= end_date)

    return query.order_by(UserStatisticsDB.date.desc()).all()

def create_or_update_statistics(db_session, stats_data: UserStatisticsUpdate) -> UserStatisticsDB:
    """
    Create or update user statistics for a specific date

    Args:
        db_session: SQLAlchemy database session
        stats_data: Statistics data

    Returns:
        The created or updated statistics entry
    """
    # Check if statistics already exist for this user and date
    existing_stats = db_session.query(UserStatisticsDB).filter(
        UserStatisticsDB.user_id == stats_data.user_id,
        UserStatisticsDB.date == stats_data.date
    ).first()

    if existing_stats:
        # Update existing statistics
        update_data = stats_data.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(existing_stats, key, value)
        db_session.commit()
        db_session.refresh(existing_stats)
        return existing_stats
    else:
        # Create new statistics
        db_stats = UserStatisticsDB(**stats_data.dict())
        db_session.add(db_stats)
        db_session.commit()
        db_session.refresh(db_stats)
        return db_stats

def calculate_productivity_score(tasks_completed, habits_completion_rate) -> int:
    """
    Calculate a productivity score based on tasks and habits

    Args:
        tasks_completed: Number of tasks completed
        habits_completion_rate: Habit completion rate (0-100)

    Returns:
        Productivity score (0-100)
    """
    # Simple formula - you can adjust this based on your application's needs
    task_weight = 0.6
    habit_weight = 0.4

    # Task score (assume 10 tasks is a perfect score)
    task_score = min(tasks_completed * 10, 100)

    # Combine scores
    return int((task_score * task_weight) + (habits_completion_rate * habit_weight))

def update_daily_statistics(db_session, user_id: int) -> UserStatisticsDB:
    """
    Calculate and update statistics for a user for the current day

    Args:
        db_session: SQLAlchemy database session
        user_id: The user ID

    Returns:
        The updated statistics entry
    """
    today = date.today()

    # Get tasks data
    tasks_data = db_session.query(
        func.count(TaskDB.task_id).filter(TaskDB.status == 'completed').label('completed'),
        func.count(TaskDB.task_id).filter(TaskDB.status != 'completed').label('pending')
    ).filter(
        TaskDB.user_id == user_id
    ).first()

    # Get habits data
    yesterday = today - timedelta(days=1)

    # Get habit logs for today
    habit_logs = db_session.query(HabitLogDB).join(
        HabitDB, HabitDB.habit_id == HabitLogDB.habit_id
    ).filter(
        HabitDB.user_id == user_id,
        HabitLogDB.completed_date == today
    ).all()

    # Get all active habits
    all_habits = db_session.query(HabitDB).filter(
        HabitDB.user_id == user_id,
        HabitDB.is_active == True
    ).all()

    # Calculate habits completion rate
    if all_habits:
        habits_completion_rate = (len(habit_logs) / len(all_habits)) * 100
    else:
        habits_completion_rate = 0

    # Calculate longest streak (simplified)
    # For a more accurate streak calculation, you would need a more complex algorithm
    habits_streak = 0

    # Calculate AI interaction stats
    ai_data = db_session.query(
        func.count(AIInteractionDB.interaction_id).label('interaction_count')
    ).filter(
        AIInteractionDB.user_id == user_id,
        func.date(AIInteractionDB.created_at) == today
    ).first()

    ai_interaction_count = ai_data.interaction_count if ai_data else 0

    # Calculate productivity score
    productivity_score = calculate_productivity_score(
        tasks_data.completed if tasks_data else 0,
        habits_completion_rate
    )

    # Create or update statistics
    stats_data = UserStatisticsUpdate(
        user_id=user_id,
        date=today,
        tasks_completed=tasks_data.completed if tasks_data else 0,
        tasks_pending=tasks_data.pending if tasks_data else 0,
        habits_streak=habits_streak,
        habits_completion_rate=round(habits_completion_rate, 2),
        productivity_score=productivity_score,
        last_active_date=datetime.now(),
        ai_interaction_count=ai_interaction_count,
        # We would need more data to calculate this accurately
        ai_suggestion_adoption_rate=0
    )

    return create_or_update_statistics(db_session, stats_data)