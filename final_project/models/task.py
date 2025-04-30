from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from ..db import Base

class TaskDB(Base):
    __tablename__ = "tasks"

    task_id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)

    # Replace admin reference with user reference
    created_by_user_id = Column(
        Integer,
        ForeignKey("users.user_id", ondelete="SET NULL"),
        nullable=True
    )

    created_at = Column(
        DateTime,
        server_default=func.now(),
        nullable=False
    )
    last_updated = Column(
        DateTime,
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )
    is_completed = Column(Boolean, default=False, nullable=False)

    # Relationship to UserDB
    user = relationship(
        "UserDB",
        back_populates="tasks",
        foreign_keys=[created_by_user_id]
    )

    # Other relationships
    task_categories = relationship(
        "TaskCategoryDB",
        back_populates="task",
        cascade="all, delete-orphan"
    )
    
    categories = relationship(
        "CategoryDB",
        secondary="task_category",
        back_populates="tasks"
    )
    # Add additional relationships as needed
