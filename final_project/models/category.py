from datetime import datetime
from sqlalchemy import (
    Column, Integer, String, Text, Boolean, DateTime,
    Numeric, Interval, ForeignKey, Index, CheckConstraint, event
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from ..db import Base

class CategoryDB(Base):
    __tablename__ = "category"

    # Columns
    category_id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    color = Column(String(50), nullable=True)
    color_name = Column(String(100), nullable=True)
    icon = Column(String(100), nullable=True)
    location = Column(String(255), nullable=True)
    repeat = Column(String(100), nullable=True)
    station = Column(String(255), nullable=True)
    remainder = Column(DateTime, nullable=True)
    progress_time = Column(Interval, nullable=True)
    progress_length = Column(Numeric, nullable=True)
    progress_weight = Column(Numeric, nullable=True)
    is_system = Column(Boolean, default=False, nullable=False)
    ai_recommended = Column(Boolean, default=False, nullable=False)

    created_by_user_id = Column(
        Integer,
        ForeignKey("users.user_id", ondelete="SET NULL"),
        nullable=True
    )
    parent_id = Column(
        Integer,
        ForeignKey("category.category_id", ondelete="SET NULL"),
        nullable=True
    )
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, nullable=False, server_default=func.now(), onupdate=func.now())

    # Indexes
    __table_args__ = (
        Index("idx_category_parent_id", "parent_id"),
        Index("idx_category_created_by_user", "created_by_user_id"),
    )

    # Relationships

    # Link to the user who created this category
    creator_user = relationship(
        "UserDB",
        back_populates="categories_created",
        foreign_keys=[created_by_user_id]
    )

    # Self-referential relationship for parent and subcategories
    parent = relationship(
        "CategoryDB",
        remote_side=[category_id],
        backref="subcategories",
        foreign_keys=[parent_id]
    )

    # Relationship with HabitCategoryDB
    habit_categories = relationship(
        "HabitCategoryDB",
        back_populates="category",
        cascade="all, delete-orphan"
    )

    # Relationship with HabitLogDB
    habit_logs = relationship(
        "HabitLogDB",
        back_populates="category",
        cascade="all, delete-orphan"
    )

    # Relationship with TaskCategoryDB
    task_categories = relationship(
        "TaskCategoryDB",
        back_populates="category",
        cascade="all, delete-orphan"
    )

    # Many-to-many relationship with TaskDB (through task_category table)
    tasks = relationship(
        "TaskDB",
        secondary="task_category",
        back_populates="categories"
    )

    # Relationship with AITrainingTextDB
    training_texts = relationship(
        "AITrainingTextDB",
        back_populates="category",
        cascade="all, delete-orphan"
    )

    # Relationship with DefaultHabitDB
    default_habits = relationship(
        "DefaultHabitDB",
        back_populates="category",
        cascade="all, delete-orphan"
    )

# Event listener to update 'updated_at' timestamp before updates
@event.listens_for(CategoryDB, 'before_update')
def _update_timestamp(mapper, connection, target):
    target.updated_at = datetime.utcnow()
