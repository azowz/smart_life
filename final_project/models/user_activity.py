from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Index
from sqlalchemy.dialects.postgresql import JSON
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship

from final_project.db import Base

# SQLAlchemy model for logging user activities
class UserActivityDB(Base):
    __tablename__ = "user_activity"

    activity_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)  # Link to UserDB
    activity_type = Column(String(50), nullable=False)  # Type of activity (e.g., "login", "task_completed")
    entity_id = Column(Integer)  # Optional related entity ID
    entity_type = Column(String(50))  # Optional related entity type
    ai_interaction = Column(Boolean, default=False)  # Whether this activity involves AI interaction
    created_at = Column(DateTime, server_default=func.now())  # Activity timestamp
    device_info = Column(JSON)  # JSON field to store device information (optional)

    __table_args__ = (
        Index("idx_user_activity_user_id", "user_id"),  # Index on user_id
        Index("idx_user_activity_activity_type", "activity_type"),  # Index on activity_type
        Index("idx_user_activity_created_at", "created_at"),  # Index on created_at
        Index("idx_user_activity_entity", "entity_id", "entity_type"),  # Composite index on entity_id and entity_type
        Index("idx_user_activity_ai_interaction", "ai_interaction"),  # Index on ai_interaction
    )

    # Relationship with UserDB
    user = relationship("UserDB", back_populates="activities")

