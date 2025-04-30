from datetime import datetime

from sqlalchemy import (
    Column, Integer, Boolean, DateTime, ForeignKey, Index, event
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from ..db import Base

class UserDefaultHabitDB(Base):
    __tablename__ = "user_default_habit"

    user_default_habit_id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    default_habit_id = Column(Integer, ForeignKey("default_habit.default_habit_id", ondelete="CASCADE"), nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)

    __table_args__ = (
        Index("idx_user_default_habit_user_id", "user_id"),
        Index("idx_user_default_habit_default_habit_id", "default_habit_id"),
        Index("idx_user_default_habit_is_active", "is_active"),
    )

    # ✅ Relationships
    user = relationship("UserDB", back_populates="user_default_habits", foreign_keys=[user_id])
    default_habit = relationship("DefaultHabitDB", back_populates="user_habits")

# ✅ Event listener for updated_at
@event.listens_for(UserDefaultHabitDB, 'before_update')
def _update_timestamp(mapper, connection, target):
    target.updated_at = datetime.utcnow()
