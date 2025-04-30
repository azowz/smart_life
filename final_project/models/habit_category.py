from sqlalchemy import Column, Integer, DateTime, ForeignKey, PrimaryKeyConstraint, Index, event
from sqlalchemy.sql import func
from datetime import datetime
from sqlalchemy.orm import relationship
from final_project.db import Base

# SQLAlchemy model for the many-to-many association between habits and categories
class HabitCategoryDB(Base):
    __tablename__ = "habit_category"

    habit_id = Column(Integer, ForeignKey("habits.habit_id", ondelete="CASCADE"), primary_key=True)  # Link to HabitDB
    category_id = Column(Integer, ForeignKey("category.category_id", ondelete="CASCADE"), primary_key=True)  # Link to CategoryDB
    created_at = Column(DateTime, server_default=func.now())  # Creation timestamp
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())  # Last updated timestamp

    __table_args__ = (
        PrimaryKeyConstraint('habit_id', 'category_id'),  # Composite primary key
        Index("idx_habit_category_habit_id", "habit_id"),  # Index on habit_id
        Index("idx_habit_category_category_id", "category_id"),  # Index on category_id
    )

    # Relationships
    habit = relationship("HabitDB", back_populates="habit_categories")  # Relationship with HabitDB
    category = relationship("CategoryDB", back_populates="habit_categories")  # Corrected relationship with CategoryDB

# Optional: remove the event listener since updated_at handles updates automatically
