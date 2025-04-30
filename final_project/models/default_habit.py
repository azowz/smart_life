from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Text, Boolean, DateTime,
    Numeric, ForeignKey, Index, CheckConstraint, event
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from ..db import Base

# SQLAlchemy model for storing default habits recommended to users
class DefaultHabitDB(Base):
    __tablename__ = "default_habit"

    # Columns
    default_habit_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key
    name = Column(String(100), nullable=False)  # Habit name
    description = Column(Text, nullable=True)  # Optional habit description
    frequency = Column(String(50), nullable=False)  # Frequency (daily, weekly, monthly)
    category_id = Column(Integer, ForeignKey("category.category_id", ondelete="SET NULL"), nullable=True)  # Link to CategoryDB
    created_by_user_id = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"), nullable=True)  # Creator user reference
    is_active = Column(Boolean, default=True, nullable=False)  # Active status flag
    effectiveness_score = Column(Numeric(3, 2), default=0.00, nullable=False)  # Effectiveness score (0.00 - 9.99)
    ai_recommended = Column(Boolean, default=False, nullable=False)  # AI recommendation flag
    adoption_rate = Column(Numeric(5, 2), default=0.00, nullable=False)  # Adoption rate (percentage)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)  # Creation timestamp
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)  # Last update timestamp

    # Indexes and constraints
    __table_args__ = (
        Index("idx_default_habit_category_id", "category_id"),
        Index("idx_default_habit_is_active", "is_active"),
        Index("idx_default_habit_effectiveness_score", "effectiveness_score"),
        Index("idx_default_habit_ai_recommended", "ai_recommended"),
        CheckConstraint(
            "frequency IN ('daily', 'weekly', 'monthly')",
            name="check_default_habit_frequency"
        ),
    )

    # Relationships

    # Many-to-one relationship with CategoryDB (each habit belongs to a category)
    category = relationship(
        "CategoryDB",
        back_populates="default_habits"
    )

    # Many-to-one relationship with UserDB (creator of the habit)
    user = relationship(
        "UserDB",
        foreign_keys=[created_by_user_id]
    )

    # One-to-many relationship with UserDefaultHabitDB (users assigned to this habit)
    user_habits = relationship(
        "UserDefaultHabitDB",
        back_populates="default_habit",
        cascade="all, delete-orphan"
    )

# Event listener to update 'updated_at' timestamp before updates
@event.listens_for(DefaultHabitDB, 'before_update')
def _update_timestamp(mapper, connection, target):
    target.updated_at = datetime.utcnow()
