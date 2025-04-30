from sqlalchemy import Column, Integer, String, Text, Date, Time, Boolean, CheckConstraint, ForeignKey, Index
from sqlalchemy.dialects.postgresql import JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from final_project.db import Base

# SQLAlchemy model for tracking user habits
class HabitDB(Base):
    __tablename__ = "habits"

    habit_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)  # Link to UserDB
    name = Column(String(100), nullable=False)  # Habit name
    color = Column(String(20), default="#4287f5")  # Hex color code
    color_name = Column(String(30))  # Optional color name
    description = Column(Text)  # Habit description
    frequency = Column(String(10), nullable=False, default="daily")  # Frequency: daily, weekly, monthly
    reminders = Column(JSON, default=[])  # Reminders as JSON array
    time = Column(Time)  # Habit time
    start_date = Column(Date, default=func.current_date())  # Start date
    target_count = Column(Integer, default=1)  # Target count
    is_default_habit = Column(Boolean, default=False)  # Flag for default habits
    default_habit_id = Column(Integer, ForeignKey("habits.habit_id", ondelete="SET NULL"))  # Self-referencing foreign key
    ai_generated = Column(Boolean, default=False)  # Flag for AI-generated habits
    created_at = Column(Date, server_default=func.now())  # Creation timestamp

    __table_args__ = (
        CheckConstraint("frequency IN ('daily', 'weekly', 'monthly')", name="check_frequency"),  # Ensure valid frequency
        Index("idx_habits_user_id", "user_id"),  # Index on user_id
    )

    # Relationships
    user = relationship("UserDB", back_populates="habits")  # Relationship with UserDB
    derived_habits = relationship("HabitDB", backref="default_habit", remote_side=[habit_id])  # Self-referencing relationship for derived habits
    logs = relationship("HabitLogDB", back_populates="habit", cascade="all, delete-orphan")  # Relationship with HabitLogDB
    habit_categories = relationship("HabitCategoryDB", back_populates="habit", cascade="all, delete-orphan")
