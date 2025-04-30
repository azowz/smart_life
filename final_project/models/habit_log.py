from sqlalchemy import Column, Integer, Text, Date, Numeric, ForeignKey, Index
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from final_project.db import Base
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from final_project.models.habit import HabitDB
    from final_project.models.category import CategoryDB
    from final_project.models.user import UserDB  # Add this

class HabitLogDB(Base):
    __tablename__ = "habit_logs"

    log_id = Column(Integer, primary_key=True, autoincrement=True)
    habit_id = Column(Integer, ForeignKey("habits.habit_id", ondelete="CASCADE"), nullable=False)
    category_id = Column(Integer, ForeignKey("category.category_id", ondelete="SET NULL"))
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)  # ✅ Add this
    completed_date = Column(Date, default=func.current_date())
    notes = Column(Text)
    value = Column(Numeric)

    __table_args__ = (
        Index("idx_habit_logs_habit_id", "habit_id"),
        Index("idx_habit_logs_date", "completed_date"),
        Index("idx_habit_logs_user_id", "user_id"),  # ✅ Add index for user_id
        {'extend_existing': True}
    )

    habit = relationship("HabitDB", back_populates="logs")
    category = relationship("CategoryDB", back_populates="habit_logs")
    user = relationship("UserDB", back_populates="habit_logs")  # ✅ Add this
