from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, Index
from sqlalchemy.sql import func
from final_project.db import Base

# SQLAlchemy model for storing chat messages between users and AI
class ChatMessageDB(Base):
    __tablename__ = "chat_message"

    message_id = Column(Integer, primary_key=True, autoincrement=True)  # Primary key
    user_id = Column(Integer, ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)  # Link to UserDB
    content = Column(Text, nullable=False)  # Message content
    is_ai_response = Column(Boolean, default=False)  # Whether this message is from AI
    created_at = Column(DateTime, server_default=func.now())  # Message creation timestamp
    related_entity_id = Column(Integer)  # Related entity ID (optional)
    related_entity_type = Column(String(50))  # Related entity type (optional)

    __table_args__ = (
        Index("idx_chat_message_user_id", "user_id"),  # Index on user_id
        Index("idx_chat_message_created_at", "created_at"),  # Index on created_at
        Index("idx_chat_message_related_entity", "related_entity_id", "related_entity_type"),  # Composite index for related entities
    )

    # Relationships
    # user = relationship("UserDB", back_populates="chat_messages")
