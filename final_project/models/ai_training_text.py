from datetime import datetime
from enum import Enum

from sqlalchemy import (
    Column, Integer, String, Text, Boolean, DateTime,
    Numeric, ForeignKey, CheckConstraint, Index, event
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from ..db import Base

# Enum for AI training text content types
class ContentType(str, Enum):
    HABIT_DESCRIPTION = "habit_description"
    TASK_EXAMPLE = "task_example"
    BEST_PRACTICE = "best_practice"

class AITrainingTextDB(Base):
    __tablename__ = "ai_training_text"

    text_id = Column(Integer, primary_key=True, autoincrement=True)
    content = Column(Text, nullable=False)
    content_type = Column(String(50), nullable=False)
    category_id = Column(Integer, ForeignKey("category.category_id", ondelete="SET NULL"), nullable=True)
    description = Column(Text, nullable=True)
    created_by_user_id = Column(Integer, ForeignKey("users.user_id", ondelete="SET NULL"), nullable=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
    usage_count = Column(Integer, default=0, nullable=False)
    effectiveness_rating = Column(Numeric(3, 2), nullable=True)
    is_active = Column(Boolean, default=True, nullable=False)

    __table_args__ = (
        CheckConstraint(
            "content_type IN ('habit_description', 'task_example', 'best_practice')",
            name="check_content_type"
        ),
        Index("idx_ai_training_text_content_type", "content_type"),
        Index("idx_ai_training_text_category_id", "category_id"),
        Index("idx_ai_training_text_is_active", "is_active"),
    )

    # Relationships
  
    user = relationship(
        "UserDB",
        back_populates="ai_training_texts",
        foreign_keys=[created_by_user_id]
    )

    category = relationship("CategoryDB", back_populates="training_texts")

# Event listener to update 'updated_at' before updates
@event.listens_for(AITrainingTextDB, 'before_update')
def _update_timestamp(mapper, connection, target):
    target.updated_at = datetime.utcnow()
