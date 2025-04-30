from sqlalchemy import Column, Integer, Numeric, DateTime, Date, ForeignKey, Index, UniqueConstraint
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from final_project.db import Base

# SQLAlchemy model for tracking user statistics
class UserStatisticsDB(Base):
    __tablename__ = "user_statistics"

    stat_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key
    user_id = Column(Integer, ForeignKey("users.user_id"), nullable=False)  # Link to UserDB
    tasks_completed = Column(Integer, default=0)  # Total tasks completed by the user
    tasks_pending = Column(Integer, default=0)  # Total tasks pending for the user
    habits_streak = Column(Integer, default=0)  # Current habit streak
    habits_completion_rate = Column(Numeric(5, 2), default=0.00)  # Habits completion rate (percentage)
    productivity_score = Column(Integer, default=0)  # Productivity score
    login_frequency = Column(Numeric(5, 2), default=0.00)  # Login frequency (e.g., logins per week)
    last_active_date = Column(DateTime)  # Last active timestamp
    ai_interaction_count = Column(Integer, default=0)  # Number of AI interactions
    ai_suggestion_adoption_rate = Column(Numeric(5, 2), default=0.00)  # Adoption rate of AI suggestions (percentage)
    date = Column(Date, nullable=False)  # Date for this statistics record

    __table_args__ = (
        UniqueConstraint("user_id", "date", name="uq_user_statistics_user_date"),  # Ensure one record per user per date
        Index("idx_user_statistics_user_id", "user_id"),  # Index on user_id
        Index("idx_user_statistics_date", "date"),  # Index on date
        Index("idx_user_statistics_productivity_score", "productivity_score"),  # Index on productivity_score
    )

    # Relationship with UserDB
    user = relationship("UserDB", backref="statistics")